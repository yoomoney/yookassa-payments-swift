import YooKassaPaymentsApi

final class BankCardRepeatPresenter {

    // MARK: - VIPER

    var router: BankCardRepeatRouterInput!
    var interactor: BankCardRepeatInteractorInput!

    weak var moduleOutput: TokenizationModuleOutput?
    weak var view: BankCardRepeatViewInput?

    // MARK: - Init data

    private let cardService: CardService
    private let paymentMethodViewModelFactory: PaymentMethodViewModelFactory
    private let priceViewModelFactory: PriceViewModelFactory

    private let isLoggingEnabled: Bool
    private let returnUrl: String?

    private let paymentMethodId: String
    private let shopName: String
    private let purchaseDescription: String
    private let termsOfService: TermsOfService
    private let savePaymentMethodViewModel: SavePaymentMethodViewModel?
    private var initialSavePaymentMethod: Bool
    private let isSafeDeal: Bool

    // MARK: - Init

    init(
        cardService: CardService,
        paymentMethodViewModelFactory: PaymentMethodViewModelFactory,
        priceViewModelFactory: PriceViewModelFactory,
        isLoggingEnabled: Bool,
        returnUrl: String?,
        paymentMethodId: String,
        shopName: String,
        purchaseDescription: String,
        termsOfService: TermsOfService,
        savePaymentMethodViewModel: SavePaymentMethodViewModel?,
        initialSavePaymentMethod: Bool,
        isSafeDeal: Bool
    ) {
        self.cardService = cardService
        self.paymentMethodViewModelFactory = paymentMethodViewModelFactory
        self.priceViewModelFactory = priceViewModelFactory

        self.isLoggingEnabled = isLoggingEnabled
        self.returnUrl = returnUrl

        self.paymentMethodId = paymentMethodId
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.termsOfService = termsOfService
        self.savePaymentMethodViewModel = savePaymentMethodViewModel
        self.initialSavePaymentMethod = initialSavePaymentMethod
        self.isSafeDeal = isSafeDeal
    }

    // MARK: - Stored Data

    private var paymentMethod: PaymentMethod?
    private var paymentOption: PaymentOption?
    private var csc: String?
}

// MARK: - BankCardRepeatViewOutput

extension BankCardRepeatPresenter: BankCardRepeatViewOutput {
    func setupView() {
        guard let view = view else { return }

        view.showActivity()
        interactor.startAnalyticsService()

        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            let (authType, _) = interactor.makeTypeAnalyticsParameters()
            let event: AnalyticsEvent = .screenPaymentContract(
                authType: authType,
                scheme: .recurringCard,
                sdkVersion: Bundle.frameworkVersion
            )
            interactor.trackEvent(event)
            interactor.fetchPaymentMethods()
        }
    }

    func didTapActionButton() {
        view?.endEditing(true)
        view?.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.tokenize()
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
        let savePaymentMethodModuleinputData = SavePaymentMethodInfoModuleInputData(
            headerValue: SavePaymentMethodInfoLocalization.BankCard.header,
            bodyValue: SavePaymentMethodInfoLocalization.BankCard.body
        )
        router.presentSavePaymentMethodInfo(
            inputData: savePaymentMethodModuleinputData
        )
    }

    func didChangeSavePaymentMethodState(
        _ state: Bool
    ) {
        initialSavePaymentMethod = state
    }

    func didSetCsc(
        _ csc: String
    ) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.csc = csc
            do {
                try self.cardService.validate(csc: csc)
            } catch {
                if error is CardService.ValidationError {
                    DispatchQueue.main.async { [weak self] in
                        guard let view = self?.view else { return }
                        view.setConfirmButtonEnabled(false)
                    }
                    return
                }
            }
            DispatchQueue.main.async { [weak self] in
                guard let view = self?.view else { return }
                view.setConfirmButtonEnabled(true)
            }
        }
    }

    func endEditing() {
        guard let csc = csc else {
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

// MARK: - BankCardRepeatInteractorOutput

extension BankCardRepeatPresenter: BankCardRepeatInteractorOutput {
    func didFetchPaymentMethod(
        _ paymentMethod: PaymentMethod
    ) {
        self.paymentMethod = paymentMethod

        guard let card = paymentMethod.card,
              card.first6.isEmpty == false,
              card.last4.isEmpty == false else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.moduleOutput?.didFinish(
                    on: self,
                    with: .paymentMethodNotFound
                )
            }
            return
        }

        guard let paymentOption = self.paymentOption else {
            assertionFailure("PaymentOption should be")
            return
        }

        let cardMask = card.first6 + "••••••" + card.last4
        let cardLogo = paymentMethodViewModelFactory.makeBankCardImage(
            first6Digits: card.first6, bankCardType: card.cardType
        )
        let priceViewModel = priceViewModelFactory.makeAmountPriceViewModel(paymentOption)
        let feeViewModel = priceViewModelFactory.makeFeePriceViewModel(paymentOption)

        let viewModel = BankCardRepeatViewModel(
            shopName: shopName,
            description: purchaseDescription,
            price: priceViewModel,
            fee: feeViewModel,
            cardMask: formattingCardMask(cardMask),
            cardLogo: cardLogo,
            terms: termsOfService,
            safeDealText: isSafeDeal ? PaymentMethodResources.Localized.safeDealInfoLink : nil
        )

        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let view = self.view else { return }

            view.hideActivity()

            view.setupViewModel(viewModel)
            view.setConfirmButtonEnabled(false)

            if let savePaymentMethodViewModel = self.savePaymentMethodViewModel {
                view.setSavePaymentMethodViewModel(savePaymentMethodViewModel)
            }

            DispatchQueue.global().async { [weak self] in
                let event: AnalyticsEvent = .screenRecurringCardForm(
                    sdkVersion: Bundle.frameworkVersion
                )
                self?.interactor.trackEvent(event)
            }
        }
    }

    func didFailFetchPaymentMethod(_ error: Error) {
        let event = AnalyticsEvent.screenError(
            authType: .withoutAuth,
            scheme: .recurringCard,
            sdkVersion: Bundle.frameworkVersion
        )
        interactor.trackEvent(event)

        let message = makeMessage(error)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.showPlaceholder(with: message)
        }
    }

    func didTokenize(_ tokens: Tokens) {
        interactor.stopAnalyticsService()
        moduleOutput?.tokenizationModule(
            self,
            didTokenize: tokens,
            paymentMethodType: .bankCard
        )

        DispatchQueue.global().async { [weak self] in
            guard let self = self, let interactor = self.interactor else { return }
            let type = interactor.makeTypeAnalyticsParameters()
            let event: AnalyticsEvent = .actionTokenize(
                scheme: .recurringCard,
                authType: type.authType,
                tokenType: type.tokenType,
                sdkVersion: Bundle.frameworkVersion
            )
            interactor.trackEvent(event)
        }
    }

    func didFailTokenize(_ error: Error) {
        let message = makeMessage(error)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.showPlaceholder(with: message)
        }
    }

    func didFetchPaymentMethods(_ paymentMethods: [PaymentOption]) {
        guard let bankCard = paymentMethods.first(where: {
            $0.paymentMethodType == .bankCard
        }) else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                      let view = self.view else { return }
                view.hideActivity()
                view.showPlaceholder()
            }
            return
        }
        self.paymentOption = bankCard
        interactor.fetchPaymentMethod(
            paymentMethodId: paymentMethodId
        )
    }

    func didFetchPaymentMethods(_ error: Error) {
        let message = makeMessage(error)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.showPlaceholder(with: message)
        }
    }

    private func tokenize() {
        guard let csc = csc else { return }

        let confirmation = Confirmation(
            type: .redirect,
            returnUrl: returnUrl ?? GlobalConstants.returnUrl
        )

        guard let paymentOption = paymentOption else {
            assertionFailure("PaymentOption should be")
            return
        }

        interactor.tokenize(
            amount: paymentOption.charge.plain,
            confirmation: confirmation,
            savePaymentMethod: initialSavePaymentMethod,
            paymentMethodId: paymentMethodId,
            csc: csc
        )
    }
}

// MARK: - ActionTitleTextDialogDelegate

extension BankCardRepeatPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(
        in actionTitleTextDialog: ActionTitleTextDialog
    ) {
        guard let view = view else { return }
        view.hidePlaceholder()
        view.showActivity()

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            if self.paymentOption == nil {
                self.interactor.fetchPaymentMethods()
            } else if self.paymentMethod == nil {
                self.interactor.fetchPaymentMethod(
                    paymentMethodId: self.paymentMethodId
                )
            } else {
                self.tokenize()
            }
        }
    }
}

// MARK: - TokenizationModuleInput

extension BankCardRepeatPresenter: TokenizationModuleInput {
    func start3dsProcess(
        requestUrl: String
    ) {
        let moduleInputData = CardSecModuleInputData(
            requestUrl: requestUrl,
            redirectUrl: returnUrl ?? GlobalConstants.returnUrl,
            isLoggingEnabled: isLoggingEnabled,
            isConfirmation: false
        )
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.present3dsModule(
                inputData: moduleInputData,
                moduleOutput: self
            )
        }
    }

    func startConfirmationProcess(
        confirmationUrl: String,
        paymentMethodType: PaymentMethodType
    ) {
        let moduleInputData = CardSecModuleInputData(
            requestUrl: confirmationUrl,
            redirectUrl: returnUrl ?? GlobalConstants.returnUrl,
            isLoggingEnabled: isLoggingEnabled,
            isConfirmation: true
        )
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.present3dsModule(
                inputData: moduleInputData,
                moduleOutput: self
            )
        }
    }
}

// MARK: - CardSecModuleOutput

extension BankCardRepeatPresenter: CardSecModuleOutput {
    func didSuccessfullyPassedCardSec(
        on module: CardSecModuleInput,
        isConfirmation: Bool
    ) {
        if isConfirmation {
            moduleOutput?.didSuccessfullyConfirmation(
                paymentMethodType: .bankCard
            )
        } else {
            moduleOutput?.didSuccessfullyPassedCardSec(
                on: self
            )
        }
    }

    func didPressCloseButton(on module: CardSecModuleInput) {
        view?.hideActivity()
        router.closeCardSecModule()
    }

    func viewWillDisappear() {
        view?.hideActivity()
    }
}

// MARK: - BankCardRepeatModuleInput

extension BankCardRepeatPresenter: BankCardRepeatModuleInput {
    func didFinish(
        on module: TokenizationModuleInput,
        with error: YooKassaPaymentsError?
    ) {
        moduleOutput?.didFinish(
            on: module,
            with: error
        )
    }
}

// MARK: - Private global helpers

private func makeMessage(_ error: Error) -> String {
    let message: String

    switch error {
    case let error as PresentableError:
        message = error.message
    default:
        message = CommonLocalized.Error.unknown
    }

    return message
}

private func formattingCardMask(_ string: String) -> String {
    return string.splitEvery(4, separator: " ")
}

private enum Constants {
    static let decimalSeparator = Locale.current.decimalSeparator ?? ","
}
