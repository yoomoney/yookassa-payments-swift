import UIKit

class BankCardPresenter {

    // MARK: - VIPER

    weak var moduleOutput: BankCardModuleOutput?
    weak var view: BankCardViewInput?
    var interactor: BankCardInteractorInput!
    var router: BankCardRouterInput!

    // MARK: - Initialization

    private let shopName: String
    private let purchaseDescription: String
    private let priceViewModel: PriceViewModel
    private let feeViewModel: PriceViewModel?
    private let termsOfService: TermsOfService
    private let cardScanning: CardScanning?
    private let savePaymentMethodViewModel: SavePaymentMethodViewModel?
    private var initialSavePaymentMethod: Bool

    init(
        shopName: String,
        purchaseDescription: String,
        priceViewModel: PriceViewModel,
        feeViewModel: PriceViewModel?,
        termsOfService: TermsOfService,
        cardScanning: CardScanning?,
        savePaymentMethodViewModel: SavePaymentMethodViewModel?,
        initialSavePaymentMethod: Bool
    ) {
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.priceViewModel = priceViewModel
        self.feeViewModel = feeViewModel
        self.termsOfService = termsOfService
        self.cardScanning = cardScanning
        self.savePaymentMethodViewModel = savePaymentMethodViewModel
        self.initialSavePaymentMethod = initialSavePaymentMethod
    }

    // MARK: - Stored properties

    private var cardData = CardData(
        pan: nil,
        expiryDate: nil,
        csc: nil
    )
    private var expiryDateText = ""
}

// MARK: - BankCardViewOutput

extension BankCardPresenter: BankCardViewOutput {
    func setupView() {
        guard let view = view else { return }
        let priceValue = makePrice(priceViewModel)

        var feeValue: String? = nil
        if let feeViewModel = feeViewModel {
            feeValue = "\(§Localized.fee) " + makePrice(feeViewModel)
        }

        let termsOfServiceValue = makeTermsOfService(
            termsOfService,
            font: UIFont.dynamicCaption2,
            foregroundColor: UIColor.AdaptiveColors.secondary
        )
        let viewModel = BankCardViewModel(
            shopName: shopName,
            description: purchaseDescription,
            priceValue: priceValue,
            feeValue: feeValue,
            termsOfService: termsOfServiceValue
        )
        view.setViewModel(viewModel)
        view.setSubmitButtonEnabled(false)
        cardScanning != nil
            ? view.setCardViewMode(.scan)
            : view.setCardViewMode(.empty)

        if let savePaymentMethodViewModel = savePaymentMethodViewModel {
            view.setSavePaymentMethodViewModel(
                savePaymentMethodViewModel
            )
        }
    }

    func didPressSubmitButton() {
        guard let view = view else { return }
        view.showActivity()
        view.endEditing(true)

        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            interactor.tokenizeBankCard(
                cardData: self.cardData,
                savePaymentMethod: self.initialSavePaymentMethod
            )
        }
    }

    func didTapTermsOfService(
        _ url: URL
    ) {
        router.presentTermsOfServiceModule(url)
    }

    func scanDidPress() {
        router?.openCardScanner()
    }

    func didChangePan(
        _ value: String
    ) {
        cardData.pan = value
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.interactor.validate(
                cardData: self.cardData,
                shouldMoveFocus: true
            )
            self.interactor.fetchBankCardSettings(value)
        }
    }

    func didChangeExpiryDate(
        _ value: String
    ) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            defer {
                self.interactor.validate(
                    cardData: self.cardData,
                    shouldMoveFocus: true
                )
            }
            self.expiryDateText = value
            guard value.count == 4 else {
                self.cardData.expiryDate = nil
                return
            }

            guard let components = makeExpiryDate(value) else {
                self.cardData.expiryDate = nil
                return
            }

            self.cardData.expiryDate = components
        }
    }

    func didChangeCvc(
        _ value: String
    ) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.cardData.csc = value
            self.interactor.validate(
                cardData: self.cardData,
                shouldMoveFocus: true
            )
        }
    }

    func didTapOnSavePaymentMethod() {
        let savePaymentMethodModuleInputData = SavePaymentMethodInfoModuleInputData(
            headerValue: §SavePaymentMethodInfoLocalization.BankCard.header,
            bodyValue: §SavePaymentMethodInfoLocalization.BankCard.body
        )
        router.presentSavePaymentMethodInfo(
            inputData: savePaymentMethodModuleInputData
        )
    }

    func didChangeSavePaymentMethodState(
        _ state: Bool
    ) {
        initialSavePaymentMethod = state
    }

    func panDidBeginEditing() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.interactor.validate(
                cardData: self.cardData,
                shouldMoveFocus: false
            )
        }
    }
}

// MARK: - BankCardInteractorOutput

extension BankCardPresenter: BankCardInteractorOutput {
    func didSuccessValidateCardData() {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.setSubmitButtonEnabled(true)

            if view.focus == .pan {
                view.setCardViewMode(.next)
            }
        }
    }

    func didFailValidateCardData(
        errors: [CardService.ValidationError],
        shouldMoveFocus: Bool
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let view = self.view else { return }
            self.validatePan(errors)

            let panIsValid = errors.contains(.panInvalidLength) == false
                && errors.contains(.luhnAlgorithmFail) == false

            let dateIsValid = errors.contains(.invalidMonth) == false
                && errors.contains(.expirationDateIsExpired) == false

            view.setSubmitButtonEnabled(false)

            if shouldMoveFocus {
                self.moveFocusIfNeeded(
                    in: view,
                    panIsValid: panIsValid,
                    dateIsValid: dateIsValid
                )
            }
        }
    }

    func didFetchBankSettings(
        _ bankSettings: BankSettings
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            let image = UIImage.named(bankSettings.logoName)
                .scaled(to: Constants.scaledImageSize)
            view.setBankLogoImage(image)
        }
    }

    func didFailFetchBankSettings() {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.setBankLogoImage(nil)
        }
    }

    func didTokenize(
        _ data: Tokens
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let view = self.view else { return }
            self.moduleOutput?.bankCardModule(
                self,
                didTokenize: data,
                paymentMethodType: .bankCard
            )

            DispatchQueue.global().async { [weak self] in
                guard let self = self, let interactor = self.interactor else { return }
                let type = interactor.makeTypeAnalyticsParameters()
                let event: AnalyticsEvent = .actionTokenize(
                    scheme: .bankCard,
                    authType: type.authType,
                    tokenType: type.tokenType
                )
                interactor.trackEvent(event)
            }
        }
    }

    func didFailTokenize(
        _ error: Error
    ) {
        let message = makeMessage(error)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.presentError(with: message)
        }
    }
}

// MARK: - BankCardModuleInput

extension BankCardPresenter: BankCardModuleInput {}

// MARK: - BankCardRouterOutput

extension BankCardPresenter: BankCardDataInputRouterOutput {
    func cardScanningDidFinish(_ scannedCardInfo: ScannedCardInfo) {
        scannedCardInfo.number.map(setPanAndMoveFocusNext)
        scannedCardInfo.expiryDate.map(setExpiryDateAndMoveFocusNext)

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.interactor.validate(
                cardData: self.cardData,
                shouldMoveFocus: false
            )
            self.cardData.pan.map(self.interactor.fetchBankCardSettings)
        }
    }

    private func setPanAndMoveFocusNext(_ value: String) {
        guard let view = view else { return }
        cardData.pan = value
        view.setPanValue(value)
        view.focus = .expiryDate
    }

    private func setExpiryDateAndMoveFocusNext(_ value: String) {
        guard let view = view,
              let expiryDate = makeExpiryDate(value) else {
            return
        }

        cardData.expiryDate = expiryDate
        view.setExpiryDateValue(value)
        view.focus = .cvc
    }
}

// MARK: - Private helpers

private extension BankCardPresenter {
    func validatePan(
        _ errors: [CardService.ValidationError]
    ) {
        guard let view = view else { return }
        if !errors.contains(.luhnAlgorithmFail),
           !errors.contains(.panInvalidLength),
           !errors.contains(.panEmpty),
           view.focus == .pan {
            view.setCardViewMode(.next)
        } else if errors.contains(.panEmpty) {
            cardScanning != nil
                ? view.setCardViewMode(.scan)
                : view.setCardViewMode(.empty)
        } else if errors.contains(.luhnAlgorithmFail)
               || errors.contains(.panInvalidLength) {
            view.setCardViewMode(.clear)
        }
    }

    func moveFocusIfNeeded(
        in view: BankCardViewInput,
        panIsValid: Bool,
        dateIsValid: Bool
    ) {
        switch view.focus {
        case .pan where panIsValid:
            guard let pan = cardData.pan,
                  pan.count >= Constants.MoveFocusLength.pan else {
                break
            }
            view.focus = .expiryDate

        case .expiryDate where dateIsValid:
            guard expiryDateText.count == Constants.MoveFocusLength.expiryDate else {
                break
            }
            view.focus = .cvc

        default:
            break
        }
    }
}

// MARK: - Constants

private extension BankCardPresenter {
    enum Constants {
        static let scaledImageSize = CGSize(width: 30, height: 30)

        enum MoveFocusLength {
            static let pan = 16
            static let expiryDate = 4
        }
    }
}

// MARK: - Localized

private extension BankCardPresenter {
    enum Localized: String {
        case fee = "Contract.fee"
    }
}

// MARK: - Private global helpers

private func makeExpiryDate(
    _ expiryDate: String
) -> DateComponents? {
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

private func makeMessage(
    _ error: Error
) -> String {
    let message: String

    switch error {
    case let error as PresentableError:
        message = error.message
    default:
        message = §CommonLocalized.Error.unknown
    }

    return message
}

private func makePrice(
    _ priceViewModel: PriceViewModel
) -> String {
    priceViewModel.integerPart
        + priceViewModel.decimalSeparator
        + priceViewModel.fractionalPart
        + priceViewModel.currency
}

private func makeTermsOfService(
    _ terms: TermsOfService,
    font: UIFont,
    foregroundColor: UIColor
) -> NSMutableAttributedString {
    let attributedText: NSMutableAttributedString

    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: foregroundColor,
    ]
    attributedText = NSMutableAttributedString(
        string: "\(terms.text) ",
        attributes: attributes
    )

    let linkAttributedText = NSMutableAttributedString(
        string: terms.hyperlink,
        attributes: attributes
    )
    let linkRange = NSRange(location: 0, length: terms.hyperlink.count)
    linkAttributedText.addAttribute(.link, value: terms.url, range: linkRange)
    attributedText.append(linkAttributedText)

    return attributedText
}
