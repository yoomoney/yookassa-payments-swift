///*
// * The MIT License (MIT)
// *
// * Copyright © 2020 NBCO YooMoney LLC
// *
// * Permission is hereby granted, free of charge, to any person obtaining a copy
// * of this software and associated documentation files (the "Software"), to deal
// * in the Software without restriction, including without limitation the rights
// * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// * copies of the Software, and to permit persons to whom the Software is
// * furnished to do so, subject to the following conditions:
// *
// * The above copyright notice and this permission notice shall be included in
// * all copies or substantial portions of the Software.
// *
// * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// * THE SOFTWARE.
// */
//

import Dispatch
import Foundation

class BankCardDataInputPresenter {

    // MARK: - VIPER

    weak var view: BankCardDataInputViewInput?
    weak var moduleOutput: BankCardDataInputModuleOutput?

    var interactor: BankCardDataInputInteractorInput!
    var router: BankCardDataInputRouterInput!

    // MARK: - Init data

    fileprivate let inputData: BankCardDataInputModuleInputData

    // MARK: - Init

    init(
        inputData: BankCardDataInputModuleInputData
    ) {
        self.inputData = inputData
    }

    // MARK: - Properties

    fileprivate var cardData = CardData(pan: nil, expiryDate: nil, csc: nil)
    fileprivate var expiryDateText = ""
}

// MARK: - BankCardDataInputViewOutput

extension BankCardDataInputPresenter: BankCardDataInputViewOutput {
    func setupView() {
        guard let view = self.view else { return }
        view.setNavigationBarTitle(§Localized.navigationBarTitle)
        view.setPanInputTextControlHint(§Localized.panInput)
        view.setExpiryDateTextControlHint(§Localized.expiryDate)
        view.setCvcTextControlHint(§Localized.cvc)
        view.setConfirmButtonTitle(§Localized.confirmButtonTitle)
        view.setConfirmButtonEnabled(false)
        view.setBankLogoImage(UIImage.Bank.unknown)

        view.setPanInputScanModeIsEnabled(inputData.cardScanner != nil)

        DispatchQueue.global().async { [weak self] in
            guard let interactor = self?.interactor else { return }
            let (authType, _) = interactor.makeTypeAnalyticsParameters()
            interactor.trackEvent(.screenBankCardForm(authType))
        }
    }

    func viewDidAppear() {
        view?.focus = .pan
    }

    func viewDidDisappear() {
        view?.hideActivity()
    }

    func didSetPan(_ pan: String) {
        cardData.pan = pan
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.interactor.validate(cardData: strongSelf.cardData)
            strongSelf.interactor.fetchBankCardSettings(pan)
        }
    }

    func didSetExpiryDate(_ expiryDate: String) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let strongSelf = self else { return }
            defer {
                strongSelf.interactor.validate(cardData: strongSelf.cardData)
            }
            strongSelf.expiryDateText = expiryDate
            guard expiryDate.count == 4 else {
                strongSelf.cardData.expiryDate = nil
                return
            }

            guard let components = makeExpiryDate(expiryDate) else {
                strongSelf.cardData.expiryDate = nil
                return
            }

            strongSelf.cardData.expiryDate = components
        }
    }

    func didSetCsc(_ csc: String) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.cardData.csc = csc
            strongSelf.interactor.validate(cardData: strongSelf.cardData)
        }
    }

    func closeBarButtonItemDidPress() {
        moduleOutput?.didPressCloseBarButtonItem(on: self)
    }

    func didPressScanButton() {
        view?.endEditing(true)
        router?.openCardScanner()
    }

    func confirmButtonDidPress() {
        view?.showActivity()
        view?.endEditing(true)
        moduleOutput?.bankCardDataInputModule(self, didPressConfirmButton: cardData)
    }
}

// MARK: - BankCardDataInputInteractorOutput

extension BankCardDataInputPresenter: BankCardDataInputInteractorOutput {
    func successValidateCardData() {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.setConfirmButtonEnabled(true)
            view.setPanIsValid(true)
        }
    }

    func failValidateCardData(errors: [CardService.ValidationError]) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self, let view = strongSelf.view else { return }
            let panIsValid = errors.contains(.panInvalidLength) == false
                && errors.contains(.luhnAlgorithmFail) == false

            let dateIsValid = errors.contains(.invalidMonth) == false
                && errors.contains(.expirationDateIsExpired) == false

            view.setPanIsValid(panIsValid)
            view.setExpiryDateIsValid(dateIsValid)
            view.setConfirmButtonEnabled(false)

            strongSelf.moveFocusIfNeeded(
                in: view,
                panIsValid: panIsValid,
                dateIsValid: dateIsValid
            )
        }
    }

    func didFetchBankSettings(_ bankSettings: BankSettings) {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            let image = UIImage.named(bankSettings.logoName)
            view.setBankLogoImage(image)
        }
    }

    func didFailFetchBankSettings() {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.setBankLogoImage(UIImage.Bank.unknown)
        }
    }
}

// MARK: - BankCardDataInputModuleInput

extension BankCardDataInputPresenter: BankCardDataInputModuleInput {
    func bankCardDidTokenize(_ error: Error) {
        let message = makeMessage(error)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.showPlaceholder(message: message)

            DispatchQueue.global().async { [weak self] in
                guard let interactor = self?.interactor else { return }
                let (authType, _) = interactor.makeTypeAnalyticsParameters()
                interactor.trackEvent(.screenError(authType: authType, scheme: .bankCard))
            }
        }
    }
}

// MARK: - PlaceholderViewDelegate

extension BankCardDataInputPresenter: ActionTextDialogDelegate {
    func didPressButton() {
        guard let view = view else { return }
        view.hidePlaceholder()
        view.showActivity()
        moduleOutput?.bankCardDataInputModule(
            self,
            didPressConfirmButton: cardData
        )
    }
}

// MARK: - BankCardDataInputRouterOutput

extension BankCardDataInputPresenter: BankCardDataInputRouterOutput {
    func cardScanningDidFinish(_ scannedCardInfo: ScannedCardInfo) {
        scannedCardInfo.number.map(setPanAndMoveFocusNext)
        scannedCardInfo.expiryDate.map(setExpiryDateAndMoveFocusNext)

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.interactor.validate(cardData: self.cardData)
            self.cardData.pan.map(self.interactor.fetchBankCardSettings)
        }
    }

    private func setPanAndMoveFocusNext(_ value: String) {
        guard let view = view else { return }
        cardData.pan = value
        view.setPanInputTextControlValue(value)
        view.focus = .expiryDate
    }

    private func setExpiryDateAndMoveFocusNext(_ value: String) {
        guard let view = view,
              let expiryDate = makeExpiryDate(value) else {
            return
        }

        cardData.expiryDate = expiryDate
        view.setExpiryDateTextControlValue(value)
        view.focus = .csc
    }
}

// MARK: - Private methods

private extension BankCardDataInputPresenter {
    func moveFocusIfNeeded(
        in view: BankCardDataInputViewInput,
        panIsValid: Bool,
        dateIsValid: Bool
    ) {
        switch view.focus {
        case .pan? where panIsValid:
            guard let pan = cardData.pan, pan.count >= Constants.MoveFocusLength.pan else { break }
            view.focus = .expiryDate

        case .expiryDate? where expiryDateText.count == Constants.MoveFocusLength.expiryDate && dateIsValid:
            view.focus = .csc

        default:
            break
        }
    }
}

// MARK: - Constants

private extension BankCardDataInputPresenter {
    enum Constants {
        enum MoveFocusLength {
            static let pan = 16
            static let expiryDate = 4
        }
    }
}

// MARK: - Localized

private extension BankCardDataInputPresenter {
    enum Localized: String {
        case navigationBarTitle = "BankCardDataInput.navigationBarTitle"
        case panInput = "BankCardDataInput.panInput"
        case expiryDate = "BankCardDataInput.expiryDate"
        case cvc = "BankCardDataInput.cvc"
        case confirmButtonTitle = "BankCardDataInput.confirmButtonTitle"
    }
}

// MARK: - Helpers

private func makeMessage(_ error: Error) -> String {
    let message: String

    switch error {
    case let error as PresentableError:
        message = error.message
    default:
        message = §CommonLocalized.Error.unknown
    }

    return message
}

private func makeExpiryDate(_ expiryDate: String) -> DateComponents? {
    let separatedIndex = expiryDate.index(expiryDate.startIndex, offsetBy: 2)
    let monthString = expiryDate[..<separatedIndex]
    let yearString = expiryDate[separatedIndex...]

    guard let month = Int(monthString),
          let year = Int(["20", yearString].joined()) else {
        return nil
    }

    return DateComponents(
        calendar: Calendar(identifier: .gregorian),
        year: year,
        month: month
    )
}
