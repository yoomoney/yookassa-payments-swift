import UIKit
import YooKassaPaymentsApi
// swiftlint:disable cyclomatic_complexity
final class BankCardPresenter {

    // MARK: - VIPER

    weak var moduleOutput: BankCardModuleOutput?
    weak var view: BankCardViewInput?

    var interactor: BankCardInteractorInput!
    var router: BankCardRouterInput!

    // MARK: - Module inputs

    weak var bankCardDataInputModuleInput: BankCardDataInputModuleInput?

    // MARK: - Initialization

    private let cardService: CardService
    private let shopName: String
    private let purchaseDescription: String
    private let priceViewModel: PriceViewModel
    private let feeViewModel: PriceViewModel?
    private let termsOfService: TermsOfService
    private let cardScanning: CardScanning?
    private let clientSavePaymentMethod: SavePaymentMethod
    private let isBackBarButtonHidden: Bool
    private let instrument: PaymentInstrumentBankCard?
    private let canSaveInstrument: Bool
    private let apiSavePaymentMethod: YooKassaPaymentsApi.SavePaymentMethod
    private let paymentMethodViewModelFactory: PaymentMethodViewModelFactory
    private let isSafeDeal: Bool

    init(
        cardService: CardService,
        shopName: String,
        purchaseDescription: String,
        priceViewModel: PriceViewModel,
        feeViewModel: PriceViewModel?,
        termsOfService: TermsOfService,
        cardScanning: CardScanning?,
        isBackBarButtonHidden: Bool,
        instrument: PaymentInstrumentBankCard?,
        canSaveInstrument: Bool,
        apiSavePaymentMethod: YooKassaPaymentsApi.SavePaymentMethod,
        clientSavePaymentMethod: SavePaymentMethod,
        paymentMethodViewModelFactory: PaymentMethodViewModelFactory,
        isSafeDeal: Bool
    ) {
        self.cardService = cardService
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.priceViewModel = priceViewModel
        self.feeViewModel = feeViewModel
        self.termsOfService = termsOfService
        self.cardScanning = cardScanning
        self.isBackBarButtonHidden = isBackBarButtonHidden
        self.instrument = instrument
        self.canSaveInstrument = canSaveInstrument
        self.apiSavePaymentMethod = apiSavePaymentMethod
        self.clientSavePaymentMethod = clientSavePaymentMethod
        self.paymentMethodViewModelFactory = paymentMethodViewModelFactory
        self.isSafeDeal = isSafeDeal
    }

    // MARK: - Stored properties

    private var cardData = CardData(pan: nil, expiryDate: nil, csc: nil)
    private var saveInstrument: Bool?
}

// MARK: - BankCardViewOutput

extension BankCardPresenter: BankCardViewOutput {
    func setupView() {
        guard let view = view else { return }
        let priceValue = makePrice(priceViewModel)

        var feeValue: String?
        if let feeViewModel = feeViewModel {
            feeValue = "\(CommonLocalized.Contract.fee) " + makePrice(feeViewModel)
        }

        let termsOfServiceValue = makeTermsOfService(
            termsOfService,
            font: UIFont.dynamicCaption2,
            foregroundColor: UIColor.AdaptiveColors.secondary
        )

        let maskedNumber = instrument
            .map { ($0.first6 ?? "") + "******" + $0.last4 }
            .map(paymentMethodViewModelFactory.replaceBullets)
            ?? paymentMethodViewModelFactory.replaceBullets("******")

        let logo: UIImage
        let cscState: MaskedCardView.CscState
        if let instrument = instrument, let first6 = instrument.first6 {
            logo = paymentMethodViewModelFactory
                .makeBankCardImage(first6Digits: first6, bankCardType: instrument.cardType)

            cscState = instrument.cscRequired ? .default : .noCVC
        } else {
            logo = PaymentMethodResources.Image.bankCard
            cscState = .default
        }

        let section: PaymentRecurrencyAndDataSavingSection?
        if instrument != nil {
            switch clientSavePaymentMethod {
            case .on:
                section = PaymentRecurrencyAndDataSavingSectionFactory.make(
                    mode: .requiredRecurring,
                    output: self
                )
            case .userSelects:
                section = PaymentRecurrencyAndDataSavingSectionFactory.make(
                    mode: .allowRecurring,
                    output: self
                )
            case .off:
                section = nil
            }
        } else {
            section = PaymentRecurrencyAndDataSavingSectionFactory.make(
                clientSavePaymentMethod: clientSavePaymentMethod,
                apiSavePaymentMethod: apiSavePaymentMethod,
                canSavePaymentInstrument: canSaveInstrument,
                output: self
            )
        }

        let viewModel = BankCardViewModel(
            shopName: shopName,
            description: purchaseDescription,
            priceValue: priceValue,
            feeValue: feeValue,
            termsOfService: termsOfServiceValue,
            instrumentMode: instrument != nil,
            maskedNumber: maskedNumber.splitEvery(4, separator: " "),
            cardLogo: logo,
            safeDealText: isSafeDeal ? PaymentMethodResources.Localized.safeDealInfoLink : nil,
            recurrencyAndDataSavingSection: section
        )

        if let section = section {
            saveInstrument = section.switchValue
            switch section.mode {
            case .requiredSaveData, .requiredRecurringAndSaveData:
                saveInstrument = true
            case .requiredRecurring:
                saveInstrument = false
            default:
                break
            }
        }

        view.setViewModel(viewModel)
        view.setSubmitButtonEnabled(cscState == .noCVC)
        view.setCardState(cscState)

        view.setBackBarButtonHidden(isBackBarButtonHidden)

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let parameters = self.interactor.makeTypeAnalyticsParameters()
            let form: AnalyticsEvent = .screenBankCardForm(
                authType: parameters.authType,
                sdkVersion: Bundle.frameworkVersion
            )
            self.interactor.trackEvent(form)
            let contract = AnalyticsEvent.screenPaymentContract(
                authType: parameters.authType,
                scheme: .bankCard,
                sdkVersion: Bundle.frameworkVersion
            )
            self.interactor.trackEvent(contract)
        }
    }

    func didPressSubmitButton() {
        guard let view = view else { return }
        view.showActivity()
        view.endEditing(true)

        let saveMethod: Bool
        switch (clientSavePaymentMethod, apiSavePaymentMethod) {
        case (.off, .allowed), (.off, .forbidden), (.on, .forbidden), (.userSelects, .forbidden):
            saveMethod = false
        case (.on, .allowed):
            saveMethod = true
        case (.userSelects, .allowed):
            saveMethod = saveInstrument ?? false
        case (_, .unknown(_)):
            saveMethod = false
        default:
            saveMethod = false
        }
        let savePaymentInstrument = canSaveInstrument ? saveInstrument : false

        DispatchQueue.global().async { [weak self] in
            guard let self = self, let interactor = self.interactor else { return }
            if let instrument = self.instrument {
                interactor.tokenizeInstrument(
                    id: instrument.paymentInstrumentId,
                    csc: self.cardData.csc,
                    savePaymentMethod: saveMethod
                )
            } else {
                interactor.tokenizeBankCard(
                    cardData: self.cardData,
                    savePaymentMethod: saveMethod,
                    savePaymentInstrument: savePaymentInstrument
                )
            }
        }
    }

    func didTapTermsOfService(_ url: URL) {
        router.presentTermsOfServiceModule(url)
    }

    func didTapSafeDealInfo(_ url: URL) {
        router.presentSafeDealInfo(
            title: PaymentMethodResources.Localized.safeDealInfoTitle,
            body: PaymentMethodResources.Localized.safeDealInfoBody
        )
    }

    func didTapOnSavePaymentMethod() {
        let savePaymentMethodModuleInputData = SavePaymentMethodInfoModuleInputData(
            headerValue: SavePaymentMethodInfoLocalization.BankCard.header,
            bodyValue: SavePaymentMethodInfoLocalization.BankCard.body
        )
        router.presentSavePaymentMethodInfo(
            inputData: savePaymentMethodModuleInputData
        )
    }

    func didSetCsc(_ csc: String) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.cardData.csc = csc
            do {
                try self.cardService.validate(csc: csc)
            } catch {
                if error is CardService.ValidationError {
                    DispatchQueue.main.async { [weak self] in
                        guard let view = self?.view else { return }
                        view.setSubmitButtonEnabled(false)
                    }
                    return
                }
            }
            DispatchQueue.main.async { [weak self] in
                guard let view = self?.view else { return }
                view.setSubmitButtonEnabled(true)
            }
        }
    }

    func endEditing() {
        guard let csc = cardData.csc else {
            view?.setCardState(.error)
            return
        }

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            do {
                try self.cardService.validate(csc: csc)
            } catch {
                if error is CardService.ValidationError {
                    DispatchQueue.main.async { [weak self] in
                        guard let view = self?.view else { return }
                        view.setCardState(.error)
                    }
                    return
                }
            }
            DispatchQueue.main.async { [weak self] in
                guard let view = self?.view else { return }
                view.setCardState(.default)
            }
        }
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

            let scheme: AnalyticsEvent.TokenizeScheme
            if let instrument = self.instrument {
                scheme = instrument.cscRequired ? .customerIdLinkedCardCvc : .customerIdLinkedCard
            } else {
                scheme = .bankCard
            }

            DispatchQueue.global().async { [weak self] in
                guard let self = self, let interactor = self.interactor else { return }
                let type = interactor.makeTypeAnalyticsParameters()
                let event: AnalyticsEvent = .actionTokenize(
                    scheme: scheme,
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

// MARK: - PaymentRecurrencyAndDataSavingSectionOutput

extension BankCardPresenter: PaymentRecurrencyAndDataSavingSectionOutput {
    func didChangeSwitchValue(newValue: Bool, mode: PaymentRecurrencyAndDataSavingSection.Mode) {
        saveInstrument = newValue
    }
    func didTapInfoLink(mode: PaymentRecurrencyAndDataSavingSection.Mode) {
        switch mode {
        case .allowRecurring, .requiredRecurring:
            router.presentSafeDealInfo(
                title: CommonLocalized.CardSettingsDetails.autopayInfoTitle,
                body: CommonLocalized.CardSettingsDetails.autopayInfoDetails
            )
        case .savePaymentData, .requiredSaveData:
            router.presentSafeDealInfo(
                title: CommonLocalized.RecurrencyAndSavePaymentData.saveDataInfoTitle,
                body: CommonLocalized.RecurrencyAndSavePaymentData.saveDataInfoMessage
            )
        case .allowRecurringAndSaveData, .requiredRecurringAndSaveData:
            router.presentSafeDealInfo(
                title: CommonLocalized.RecurrencyAndSavePaymentData.saveDataAndAutopaymentsInfoTitle,
                body: CommonLocalized.RecurrencyAndSavePaymentData.saveDataAndAutopaymentsInfoMessage
            )
        default:
        break
        }
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
        message = CommonLocalized.Error.unknown
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
