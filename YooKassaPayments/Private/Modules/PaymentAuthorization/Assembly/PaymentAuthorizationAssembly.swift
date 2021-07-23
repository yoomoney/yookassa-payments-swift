enum PaymentAuthorizationAssembly {
    static func makeModule(
        inputData: PaymentAuthorizationModuleInputData,
        moduleOutput: PaymentAuthorizationModuleOutput?
    ) -> UIViewController {
        let view = PaymentAuthorizationViewController()

        let presenter = PaymentAuthorizationPresenter(
            authContextId: inputData.authContextId,
            processId: inputData.processId,
            tokenizeScheme: inputData.tokenizeScheme,
            authTypeState: inputData.authTypeState
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
        let interactor = PaymentAuthorizationInteractor(
            authorizationService: authorizationService,
            analyticsService: analyticsService,
            analyticsProvider: analyticsProvider,
            clientApplicationKey: inputData.clientApplicationKey
        )

        presenter.view = view
        presenter.interactor = interactor
        presenter.moduleOutput = moduleOutput

        interactor.output = presenter

        view.output = presenter

        return view
    }
}
