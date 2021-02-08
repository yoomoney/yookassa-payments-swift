import YooKassaPaymentsApi

final class YooMoneyPresenter {
    
    // MARK: - VIPER
    
    var interactor: YooMoneyInteractorInput!
    var router: YooMoneyRouterInput!
    
    weak var view: YooMoneyViewInput?
    weak var moduleOutput: YooMoneyModuleOutput?
    
    // MARK: - Init data
    
    fileprivate let clientApplicationKey: String
    fileprivate let testModeSettings: TestModeSettings?
    fileprivate let isLoggingEnabled: Bool
    fileprivate let moneyAuthClientId: String?
    
    fileprivate let shopName: String
    fileprivate let purchaseDescription: String
    fileprivate let price: PriceViewModel
    fileprivate let fee: PriceViewModel?
    fileprivate let paymentMethod: PaymentMethodViewModel
    fileprivate let paymentOption: PaymentInstrumentYooMoneyWallet
    fileprivate let tokenizeScheme: AnalyticsEvent.TokenizeScheme
    fileprivate let termsOfService: TermsOfService
    fileprivate let returnUrl: String?
    fileprivate let savePaymentMethodViewModel: SavePaymentMethodViewModel?
    fileprivate let tmxSessionId: String?
    fileprivate var initialSavePaymentMethod: Bool
    
    // MARK: - Init
    
    init(
        clientApplicationKey: String,
        testModeSettings: TestModeSettings?,
        isLoggingEnabled: Bool,
        moneyAuthClientId: String?,
        shopName: String,
        purchaseDescription: String,
        price: PriceViewModel,
        fee: PriceViewModel?,
        paymentMethod: PaymentMethodViewModel,
        paymentOption: PaymentInstrumentYooMoneyWallet,
        tokenizeScheme: AnalyticsEvent.TokenizeScheme,
        termsOfService: TermsOfService,
        returnUrl: String?,
        savePaymentMethodViewModel: SavePaymentMethodViewModel?,
        tmxSessionId: String?,
        initialSavePaymentMethod: Bool
    ) {
        self.clientApplicationKey = clientApplicationKey
        self.testModeSettings = testModeSettings
        self.isLoggingEnabled = isLoggingEnabled
        self.moneyAuthClientId = moneyAuthClientId
        
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.price = price
        self.fee = fee
        self.paymentMethod = paymentMethod
        self.paymentOption = paymentOption
        self.tokenizeScheme = tokenizeScheme
        self.termsOfService = termsOfService
        self.returnUrl = returnUrl
        self.savePaymentMethodViewModel = savePaymentMethodViewModel
        self.tmxSessionId = tmxSessionId
        self.initialSavePaymentMethod = initialSavePaymentMethod
    }
    
    // MARK: - Properties

    fileprivate var isReusableToken = true
}

// MARK: - YooMoneyViewOutput

extension YooMoneyPresenter: YooMoneyViewOutput {
    func setupView() {
        guard let view = view else { return }

        let viewModel = YooMoneyViewModel(
            shopName: shopName,
            description: purchaseDescription,
            price: price,
            fee: fee,
            paymentMethod: paymentMethod,
            terms: termsOfService
        )
        view.setupViewModel(viewModel)
        
        if !interactor.hasReusableWalletToken() {
            view.setSaveAuthInAppSwitchItemView()
        }
        
        if let savePaymentMethodViewModel = savePaymentMethodViewModel {
            view.setSavePaymentMethodViewModel(
                savePaymentMethodViewModel
            )
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            interactor.loadAvatar()
            
            let (authType, _) = interactor.makeTypeAnalyticsParameters()
            let event: AnalyticsEvent = .screenPaymentContract(
                authType: authType,
                scheme: self.tokenizeScheme
            )
            interactor.trackEvent(event)
        }
    }
    
    func didTapActionButton() {
        view?.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            if self.interactor.hasReusableWalletToken() {
                self.tokenize()
            } else {
                self.interactor.loginInWallet(
                    amount: self.paymentOption.charge.plain,
                    reusableToken: self.isReusableToken,
                    tmxSessionId: self.tmxSessionId
                )
            }
        }
    }
    
    func didTapLogout() {
        let walletDisplayName = interactor.getWalletDisplayName()
        let inputData = LogoutConfirmationModuleInputData(
            accountName: walletDisplayName ?? paymentOption.accountId
        )
        router.presentLogoutConfirmation(
            inputData: inputData,
            moduleOutput: self
        )
    }
    
    func didTapTermsOfService(_ url: URL) {
        router.presentTermsOfServiceModule(url)
    }
    
    func didTapOnSavePaymentMethod() {
        let savePaymentMethodModuleinputData = SavePaymentMethodInfoModuleInputData(
            headerValue: §SavePaymentMethodInfoLocalization.Wallet.header,
            bodyValue: §SavePaymentMethodInfoLocalization.Wallet.body
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
    
    func didChangeSaveAuthInAppState(
        _ state: Bool
    ) {
        isReusableToken = state
    }
}

// MARK: - ActionTitleTextDialogDelegate

extension YooMoneyPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(
        in actionTitleTextDialog: ActionTitleTextDialog
    ) {
        guard let view = view else { return }
        view.hidePlaceholder()
        view.showActivity()
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.tokenize()
        }
    }
}

// MARK: - YooMoneyInteractorOutput

extension YooMoneyPresenter: YooMoneyInteractorOutput {
    func didLoginInWallet(
        _ response: WalletLoginResponse
    ) {
        switch response {
        case .authorized:
            tokenize()
        case let .notAuthorized(
                authTypeState: authTypeState,
                processId: processId,
                authContextId: authContextId
        ):
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view?.hideActivity()
                
                let inputData = PaymentAuthorizationModuleInputData(
                    clientApplicationKey: self.clientApplicationKey,
                    testModeSettings: self.testModeSettings,
                    isLoggingEnabled: self.isLoggingEnabled,
                    moneyAuthClientId: self.moneyAuthClientId,
                    authContextId: authContextId,
                    processId: processId,
                    tokenizeScheme: self.tokenizeScheme,
                    authTypeState: authTypeState
                )
                self.router.presentPaymentAuthorizationModule(
                    inputData: inputData,
                    moduleOutput: self
                )
            }
        }
    }
    
    func failLoginInWallet(
        _ error: Error
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            
            let message = makeMessage(error)
            view.presentError(with: message)

            DispatchQueue.global().async { [weak self] in
                guard let self = self, let interactor = self.interactor else { return }
                let (authType, _) = interactor.makeTypeAnalyticsParameters()
                interactor.trackEvent(.screenError(authType: authType, scheme: self.tokenizeScheme))
            }
        }
    }
    
    func didTokenizeData(_ token: Tokens) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let view = self.view else { return }
            view.hideActivity()
            self.moduleOutput?.tokenizationModule(
                self,
                didTokenize: token,
                paymentMethodType: self.paymentOption.paymentMethodType.plain
            )

            DispatchQueue.global().async { [weak self] in
                guard let self = self, let interactor = self.interactor else { return }
                let type = interactor.makeTypeAnalyticsParameters()
                let event: AnalyticsEvent = .actionTokenize(
                    scheme: .wallet,
                    authType: type.authType,
                    tokenType: type.tokenType
                )
                interactor.trackEvent(event)
                interactor.stopAnalyticsService()
            }
        }
    }

    func failTokenizeData(_ error: Error) {
        let message = makeMessage(error)
        
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.showPlaceholder(with: message)
        }
    }
    
    func didLoadAvatar(
        _ avatar: UIImage
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.setupAvatar(avatar)
        }
    }
    
    func didFailLoadAvatar(
        _ error: Error
    ) {}
    
    private func tokenize() {
        interactor.tokenize(
            confirmation: Confirmation(type: .redirect, returnUrl: returnUrl),
            savePaymentMethod: initialSavePaymentMethod,
            paymentMethodType: paymentOption.paymentMethodType.plain,
            amount: paymentOption.charge.plain,
            tmxSessionId: tmxSessionId
        )

        interactor.trackEvent(.actionPaymentAuthorization(.success))
    }
}

// MARK: - PaymentAuthorizationModuleOutput

extension YooMoneyPresenter: PaymentAuthorizationModuleOutput {
    func didPressClose(
        _ module: PaymentAuthorizationModuleInput
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.router.closePaymentAuthorization()
        }
    }
    
    func didCheckUserAnswer(
        _ module: PaymentAuthorizationModuleInput,
        response: WalletLoginResponse
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.closePaymentAuthorization()
            self.view?.showActivity()
            self.didLoginInWallet(response)
        }
    }
}

// MARK: - LogoutConfirmationModuleOutput

extension YooMoneyPresenter: LogoutConfirmationModuleOutput {
    func logoutDidConfirm(on module: LogoutConfirmationModuleInput) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            interactor.logout()
            interactor.trackEvent(.actionLogout)
            self.moduleOutput?.didLogout(self)
        }
    }

    func logoutDidCancel(on module: LogoutConfirmationModuleInput) {}
}

// MARK: - YooMoneyModuleInput

extension YooMoneyPresenter: YooMoneyModuleInput {}

// MARK: - Make message from Error

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
