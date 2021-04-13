enum LinkedCardAssembly {
    static func makeModule(
        inputData: LinkedCardModuleInputData,
        moduleOutput: LinkedCardModuleOutput?
    ) -> UIViewController {
        let view = LinkedCardViewController()
        
        let cardService = CardService()
        let paymentMethodViewModelFactory =
            PaymentMethodViewModelFactoryAssembly.makeFactory()
        let presenter = LinkedCardPresenter(
            cardService: cardService,
            paymentMethodViewModelFactory: paymentMethodViewModelFactory,
            clientApplicationKey: inputData.clientApplicationKey,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled,
            moneyAuthClientId: inputData.moneyAuthClientId,
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            price: inputData.price,
            fee: inputData.fee,
            paymentOption: inputData.paymentOption,
            termsOfService: inputData.termsOfService,
            returnUrl: inputData.returnUrl,
            tmxSessionId: inputData.tmxSessionId,
            initialSavePaymentMethod: inputData.initialSavePaymentMethod,
            isBackBarButtonHidden: inputData.isBackBarButtonHidden
        )
        
        let authorizationService = AuthorizationServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled,
            testModeSettings: inputData.testModeSettings,
            moneyAuthClientId: inputData.moneyAuthClientId
        )
        let analyticsService = AnalyticsServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsProvider = AnalyticsProviderAssembly.makeProvider(
            testModeSettings: inputData.testModeSettings
        )
        let threatMetrixService = ThreatMetrixServiceFactory.makeService()
        let interactor = LinkedCardInteractor(
            authorizationService: authorizationService,
            analyticsService: analyticsService,
            analyticsProvider: analyticsProvider,
            paymentService: paymentService,
            threatMetrixService: threatMetrixService,
            clientApplicationKey: inputData.clientApplicationKey
        )
        
        let router = LinkedCardRouter()
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.moduleOutput = moduleOutput
        
        interactor.output = presenter
        
        view.output = presenter
        
        router.transitionHandler = view
        
        return view
    }
}
