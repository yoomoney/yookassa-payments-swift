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
import class UIKit.UIImage

final class MaskedBankCardDataInputPresenter {

    // MARK: - VIPER module properties
    weak var view: BankCardDataInputViewInput?
    weak var moduleOutput: MaskedBankCardDataInputModuleOutput?
    var interactor: BankCardDataInputInteractorInput!

    // MARK: - Module interaction properties
    fileprivate var csc: String?

    // MARK: - Module data
    fileprivate let inputData: MaskedBankCardDataInputModuleInputData
    init(inputData: MaskedBankCardDataInputModuleInputData) {
        self.inputData = inputData
    }
}

// MARK: - BankCardDataInputViewOutput
extension MaskedBankCardDataInputPresenter: BankCardDataInputViewOutput {
    func setupView() {
        guard let view = self.view else { return }

        view.setPanInputTextControlHint(§Localized.panInput)
        view.setExpiryDateTextControlHint(§Localized.expiryDate)

        view.setNavigationBarTitle(§Localized.navigationBarTitle)
        view.setCvcTextControlHint(§Localized.cvc)

        view.setConfirmButtonTitle(§Localized.confirmButtonTitle)
        view.setConfirmButtonEnabled(false)

        view.setPanInputTextControlDisabledStyle()
        view.setPanInputTextControlValue(PaymentMethodViewModelFactory.replaceBullets(inputData.cardMask))
        view.setPanInputTextControlIsEnabled(false)

        view.setExpiryDateTextControlDisabledStyle()
        view.setExpiryDateTextControlFormattedValue(Constants.expiryDateValue)
        view.setExpiryDateTextControlIsEnabled(false)

        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            self.inputData.analyticsEvent.flatMap(interactor.trackEvent)
            interactor.fetchBankCardSettings(
                makePanFromCardMask(
                    self.inputData.cardMask
                )
            )
        }
    }

    func viewDidAppear() {
        view?.focus = .csc
    }

    func viewDidDisappear() {
        view?.hideActivity()
    }

    func didSetPan(_ pan: String) {}

    func didSetExpiryDate(_ expiryDate: String) {}

    func didSetCsc(_ csc: String) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.csc = csc
            strongSelf.interactor.validate(csc: csc)
        }
    }

    func closeBarButtonItemDidPress() {
        moduleOutput?.didPressCloseBarButtonItem(on: self)
    }

    func didPressScanButton() {}
}

// MARK: - BankCardDataInputInteractorOutput
extension MaskedBankCardDataInputPresenter: BankCardDataInputInteractorOutput {
    func successValidateCardData() {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.setConfirmButtonEnabled(true)
        }
    }

    func failValidateCardData(errors: [CardService.ValidationError]) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self, let view = strongSelf.view else { return }
            view.setConfirmButtonEnabled(false)
            view.focus = .csc
        }
    }

    func confirmButtonDidPress() {
        guard let cvc = csc else { return }
        view?.showActivity()
        view?.endEditing(true)
        moduleOutput?.didPressConfirmButton(on: self,
                                            cvc: cvc)
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
extension MaskedBankCardDataInputPresenter: BankCardDataInputModuleInput {
    func bankCardDidTokenize(_ error: Error) {
        let message = makeMessage(error)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.showPlaceholder(message: message)

            DispatchQueue.global().async { [weak self] in
                guard let interactor = self?.interactor else { return }
                let (authType, _) = interactor.makeTypeAnalyticsParameters()
                let scheme = self?.inputData.tokenizeScheme
                interactor.trackEvent(.screenError(authType: authType, scheme: scheme))
            }
        }
    }
}

// MARK: - PlaceholderViewDelegate
extension MaskedBankCardDataInputPresenter: ActionTextDialogDelegate {
    // This is button in placeholder view. Need fix in UI library
    func didPressButton() {
        guard let cvc = csc else { return }
        view?.hidePlaceholder()
        view?.showActivity()
        moduleOutput?.didPressConfirmButton(on: self,
                                            cvc: cvc)
    }
}

// MARK: - Localized
private extension MaskedBankCardDataInputPresenter {
    enum Localized: String {
        case navigationBarTitle = "BankCardDataInput.navigationBarTitle"
        case panInput = "BankCardDataInput.panInput"
        case expiryDate = "BankCardDataInput.expiryDate"
        case cvc = "BankCardDataInput.cvc"
        case confirmButtonTitle = "BankCardDataInput.confirmButtonTitle"
    }
}

// MARK: - Constants
private extension MaskedBankCardDataInputPresenter {
    enum Constants {
        static let expiryDateValue = "•• / ••"
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

private func makePanFromCardMask(_ cardMask: String) -> String {
    let endIndex = cardMask.index(cardMask.startIndex, offsetBy: 6, limitedBy: cardMask.endIndex)
        ?? cardMask.index(cardMask.startIndex, offsetBy: cardMask.count, limitedBy: cardMask.endIndex)
        ?? cardMask.startIndex

    let charsWithoutDecimals = cardMask.components(separatedBy: CharacterSet.decimalDigits).joined()
    let charsWithoutDecimalsSet = CharacterSet(charactersIn: charsWithoutDecimals)
    return (cardMask[cardMask.startIndex..<endIndex]).components(separatedBy: charsWithoutDecimalsSet).joined()
}
