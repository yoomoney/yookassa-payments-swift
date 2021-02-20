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
    
    private let isLoggingEnabled: Bool
    private let returnUrl: String?

    private let paymentMethodId: String
    private let shopName: String
    private let purchaseDescription: String
    private let amount: Amount
    private let termsOfService: TermsOfService
    private let savePaymentMethodViewModel: SavePaymentMethodViewModel?
    private var initialSavePaymentMethod: Bool

    // MARK: - Init

    init(
        cardService: CardService,
        paymentMethodViewModelFactory: PaymentMethodViewModelFactory,
        isLoggingEnabled: Bool,
        returnUrl: String?,
        paymentMethodId: String,
        shopName: String,
        purchaseDescription: String,
        amount: Amount,
        termsOfService: TermsOfService,
        savePaymentMethodViewModel: SavePaymentMethodViewModel?,
        initialSavePaymentMethod: Bool
    ) {
        self.cardService = cardService
        self.paymentMethodViewModelFactory = paymentMethodViewModelFactory
        
        self.isLoggingEnabled = isLoggingEnabled
        self.returnUrl = returnUrl
        
        self.paymentMethodId = paymentMethodId
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.amount = amount
        self.termsOfService = termsOfService
        self.savePaymentMethodViewModel = savePaymentMethodViewModel
        self.initialSavePaymentMethod = initialSavePaymentMethod
    }
    
    // MARK: - Stored Data

    private var paymentMethod: PaymentMethod?
    private var csc: String?
}

// MARK: - BankCardRepeatViewOutput

extension BankCardRepeatPresenter: BankCardRepeatViewOutput {
    func setupView() {
        guard let view = view else { return }
        
        view.showActivity()
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            
            let (authType, _) = interactor.makeTypeAnalyticsParameters()
            let event: AnalyticsEvent = .screenPaymentContract(
                authType: authType,
                scheme: .recurringCard
            )
            interactor.trackEvent(event)
            interactor.fetchPaymentMethod(
                paymentMethodId: self.paymentMethodId
            )
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
    
    func didTapOnSavePaymentMethod() {
        let savePaymentMethodModuleinputData = SavePaymentMethodInfoModuleInputData(
            headerValue: §SavePaymentMethodInfoLocalization.BankCard.header,
            bodyValue: §SavePaymentMethodInfoLocalization.BankCard.body
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
                if let error = error as? CardService.ValidationError {
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
                if let error = error as? CardService.ValidationError {
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
        
        let cardMask = card.first6 + "••••••" + card.last4
        let cardLogo = paymentMethodViewModelFactory.makeBankCardImage(card)
        
        let viewModel = BankCardRepeatViewModel(
            shopName: shopName,
            description: purchaseDescription,
            price: makePriceViewModel(amount),
            cardMask: formattingCardMask(cardMask),
            cardLogo: cardLogo,
            terms: termsOfService
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
                self?.interactor.trackEvent(.screenRecurringCardForm)
            }
        }
    }

    func didFailFetchPaymentMethod(_ error: Error) {
        if let error = error as? PaymentsApiError {
            switch error.errorCode {
            case .invalidRequest, .notSupported:
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.moduleOutput?.didFinish(
                        on: self,
                        with: .paymentMethodNotFound
                    )
                }
                
            default:
                showError(error)
            }
        } else {
            showError(error)
        }
    }

    func didTokenize(_ tokens: Tokens) {
        moduleOutput?.tokenizationModule(
            self,
            didTokenize: tokens,
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

    func didFailTokenize(_ error: Error) {
        let message = makeMessage(error)
        
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.showPlaceholder(with: message)
        }
    }

    private func showError(_ error: Error) {
        let authType = AnalyticsEvent.AuthType.withoutAuth
        let scheme = AnalyticsEvent.TokenizeScheme.recurringCard
        let event = AnalyticsEvent.screenError(authType: authType, scheme: scheme)
        interactor.trackEvent(event)

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
        
        interactor.tokenize(
            amount: MonetaryAmountFactory.makeMonetaryAmount(amount),
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
            if self.paymentMethod == nil {
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
            isLoggingEnabled: isLoggingEnabled
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
    func didSuccessfullyPassedCardSec(on module: CardSecModuleInput) {
        moduleOutput?.didSuccessfullyPassedCardSec(on: self)
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

private func makePriceViewModel(
    _ amount: Amount
) -> PriceViewModel {
    let amountString = amount.value.description
    var integerPart = ""
    var fractionalPart = ""

    if let separatorIndex = amountString.firstIndex(of: ".") {
        integerPart = String(amountString[amountString.startIndex..<separatorIndex])
        fractionalPart = String(amountString[amountString.index(after: separatorIndex)..<amountString.endIndex])
    } else {
        integerPart = amountString
        fractionalPart = "00"
    }
    return TempAmount(
        currency: amount.currency.symbol,
        integerPart: integerPart,
        fractionalPart: fractionalPart,
        style: .amount
    )
}

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

private func formattingCardMask(_ string: String) -> String {
    return string.splitEvery(4, separator: " ")
}
