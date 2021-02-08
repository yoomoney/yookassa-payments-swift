enum YooMoneyAssembly {
    static func makeModule(
        inputData: YooMoneyModuleInputData,
        moduleOutput: YooMoneyModuleOutput?
    ) -> UIViewController {
        let view = YooMoneyViewController()
        
        let presenter = YooMoneyPresenter(
            clientApplicationKey: inputData.clientApplicationKey,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled,
            moneyAuthClientId: inputData.moneyAuthClientId,
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            price: inputData.price,
            fee: inputData.fee,
            paymentMethod: inputData.paymentMethod,
            paymentOption: inputData.paymentOption,
            tokenizeScheme: inputData.tokenizeScheme,
            termsOfService: inputData.termsOfService,
            returnUrl: inputData.returnUrl,
            savePaymentMethodViewModel: inputData.savePaymentMethodViewModel,
            tmxSessionId: inputData.tmxSessionId,
            initialSavePaymentMethod: inputData.initialSavePaymentMethod
        )
        
        let authorizationService = AuthorizationServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled,
            testModeSettings: inputData.testModeSettings,
            moneyAuthClientId: inputData.moneyAuthClientId
        )
        let analyticsService = AnalyticsServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsProvider = AnalyticsProviderAssembly.makeProvider(
            testModeSettings: inputData.testModeSettings
        )
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let imageDownloadService = ImageDownloadServiceFactory.makeService()
        let interactor = YooMoneyInteractor(
            authorizationService: authorizationService,
            analyticsService: analyticsService,
            analyticsProvider: analyticsProvider,
            paymentService: paymentService,
            imageDownloadService: imageDownloadService,
            clientApplicationKey: inputData.clientApplicationKey
        )
        
        let router = YooMoneyRouter()
        
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
