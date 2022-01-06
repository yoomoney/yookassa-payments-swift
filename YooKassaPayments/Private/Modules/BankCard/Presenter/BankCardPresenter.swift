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
    private let termsOfService: NSAttributedString
    private let cardScanning: CardScanning?
    private let clientSavePaymentMethod: SavePaymentMethod
    private let isBackBarButtonHidden: Bool
    private let instrument: PaymentInstrumentBankCard?
    private let canSaveInstrument: Bool
    private let apiSavePaymentMethod: YooKassaPaymentsApi.SavePaymentMethod
    private let paymentMethodViewModelFactory: PaymentMethodViewModelFactory
    private let isSafeDeal: Bool
    private let config: Config

    init(
        cardService: CardService,
        shopName: String,
        purchaseDescription: String,
        priceViewModel: PriceViewModel,
        feeViewModel: PriceViewModel?,
        termsOfService: NSAttributedString,
        cardScanning: CardScanning?,
        isBackBarButtonHidden: Bool,
        instrument: PaymentInstrumentBankCard?,
        canSaveInstrument: Bool,
        apiSavePaymentMethod: YooKassaPaymentsApi.SavePaymentMethod,
        clientSavePaymentMethod: SavePaymentMethod,
        paymentMethodViewModelFactory: PaymentMethodViewModelFactory,
        isSafeDeal: Bool,
        config: Config
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
        self.config = config
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
                    texts: config.savePaymentMethodOptionTexts,
                    output: self
                )
            case .userSelects:
                section = PaymentRecurrencyAndDataSavingSectionFactory.make(
                    mode: .allowRecurring,
                    texts: config.savePaymentMethodOptionTexts,
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
                texts: config.savePaymentMethodOptionTexts,
                output: self
            )
        }

        let viewModel = BankCardViewModel(
            shopName: shopName,
            description: purchaseDescription,
            priceValue: priceValue,
            feeValue: feeValue,
            termsOfService: termsOfService,
            instrumentMode: instrument != nil,
            maskedNumber: maskedNumber.splitEvery(4, separator: " "),
            cardLogo: logo,
            safeDealText: isSafeDeal ? PaymentMethodResources.Localized.safeDealInfoLink : nil,
            recurrencyAndDataSavingSection: section,
            paymentOptionTitle: config.paymentMethods.first { $0.kind == .bankCard }?.title
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
            self.interactor.track(event:
                .screenPaymentContract(
                    scheme: .bankCard,
                    currentAuthType: self.interactor.analyticsAuthType()
                )
            )
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
        case (_, _):
            saveMethod = false
        }
        let savePaymentInstrument = canSaveInstrument ? saveInstrument : false
        interactor.track(event: .actionTryTokenize(scheme: .bankCard, currentAuthType: interactor.analyticsAuthType()))

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
                guard let self = self else { return }
                self.interactor.track(event:
                    .actionTokenize(
                        scheme: scheme,
                        currentAuthType: self.interactor.analyticsAuthType()
                    )
                )
            }
        }
    }

    func didFailTokenize(_ error: Error) {
        interactor.track(
            event: .screenErrorContract(scheme: .bankCard, currentAuthType: interactor.analyticsAuthType())
        )

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
                title: htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOnBindOffTitle),
                body: htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOnBindOffText)
            )
        case .savePaymentData, .requiredSaveData:
            router.presentSafeDealInfo(
                title: htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOffBindOnTitle),
                body: htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOffBindOnText)
            )
        case .allowRecurringAndSaveData, .requiredRecurringAndSaveData:
            router.presentSafeDealInfo(
                title: htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOnBindOnTitle),
                body: htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOnBindOnText)
            )
        default:
        break
        }
    }

    /// Convert <br> -> \n and other html text formatting to native `String`
    private func htmlOut(source: String) -> String {
        guard let data = source.data(using: .utf16) else { return source }
        do {
            let html = try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil
            )
            return html.string
        } catch {
            return source
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
