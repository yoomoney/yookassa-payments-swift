import UIKit

final class BankCardPresenter {

    // MARK: - VIPER

    weak var moduleOutput: BankCardModuleOutput?
    weak var view: BankCardViewInput?

    var interactor: BankCardInteractorInput!
    var router: BankCardRouterInput!

    // MARK: - Module inputs

    weak var bankCardDataInputModuleInput: BankCardDataInputModuleInput?

    // MARK: - Initialization

    private let shopName: String
    private let purchaseDescription: String
    private let priceViewModel: PriceViewModel
    private let feeViewModel: PriceViewModel?
    private let termsOfService: TermsOfService
    private let cardScanning: CardScanning?
    private let savePaymentMethodViewModel: SavePaymentMethodViewModel?
    private var initialSavePaymentMethod: Bool
    private let isBackBarButtonHidden: Bool

    init(
        shopName: String,
        purchaseDescription: String,
        priceViewModel: PriceViewModel,
        feeViewModel: PriceViewModel?,
        termsOfService: TermsOfService,
        cardScanning: CardScanning?,
        savePaymentMethodViewModel: SavePaymentMethodViewModel?,
        initialSavePaymentMethod: Bool,
        isBackBarButtonHidden: Bool
    ) {
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.priceViewModel = priceViewModel
        self.feeViewModel = feeViewModel
        self.termsOfService = termsOfService
        self.cardScanning = cardScanning
        self.savePaymentMethodViewModel = savePaymentMethodViewModel
        self.initialSavePaymentMethod = initialSavePaymentMethod
        self.isBackBarButtonHidden = isBackBarButtonHidden
    }

    // MARK: - Stored properties

    private var cardData = CardData(
        pan: nil,
        expiryDate: nil,
        csc: nil
    )
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


        if let savePaymentMethodViewModel = savePaymentMethodViewModel {
            view.setSavePaymentMethodViewModel(
                savePaymentMethodViewModel
            )
        }

        view.setBackBarButtonHidden(isBackBarButtonHidden)

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let parameters = self.interactor.makeTypeAnalyticsParameters()
            let event: AnalyticsEvent = .screenBankCardForm(
                authType: parameters.authType,
                sdkVersion: Bundle.frameworkVersion
            )
            self.interactor.trackEvent(event)
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
}

// MARK: - BankCardInteractorOutput

extension BankCardPresenter: BankCardInteractorOutput {
    func didTokenize(
        _ data: Tokens
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
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
                    tokenType: type.tokenType,
                    sdkVersion: Bundle.frameworkVersion
                )
                interactor.trackEvent(event)
            }
        }
    }

    func didFailTokenize(
        _ error: Error
    ) {
        let parameters = interactor.makeTypeAnalyticsParameters()
        let event: AnalyticsEvent = .screenError(
            authType: parameters.authType,
            scheme: .bankCard,
            sdkVersion: Bundle.frameworkVersion
        )
        interactor.trackEvent(event)

        let message = makeMessage(error)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.presentError(with: message)
        }
    }
}

// MARK: - BankCardModuleInput

extension BankCardPresenter: BankCardModuleInput {
    func hideActivity() {
        view?.hideActivity()
    }
}

// MARK: - BankCardDataInputModuleOutput

extension BankCardPresenter: BankCardDataInputModuleOutput {
    func bankCardDataInputModule(
        _ module: BankCardDataInputModuleInput,
        didSuccessValidateCardData cardData: CardData
    ) {
        self.cardData = cardData
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let view = self.view else { return }
            view.setSubmitButtonEnabled(true)
        }
    }

    func bankCardDataInputModule(
        _ module: BankCardDataInputModuleInput,
        didFailValidateCardData errors: [CardService.ValidationError]
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let view = self.view else { return }
            view.setSubmitButtonEnabled(false)
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
