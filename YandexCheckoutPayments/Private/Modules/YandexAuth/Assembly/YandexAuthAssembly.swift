import class UIKit.UIViewController

enum YandexAuthAssembly {

    static func makeModule(
        inputData: YandexAuthModuleInputData,
        moduleOutput: YandexAuthModuleOutput
    ) -> PaymentMethodsViewController {
        let view = PaymentMethodsViewController()
        return YandexAuthAssembly.makeModule(inputData: inputData,
                                             moduleOutput: moduleOutput,
                                             view: view)
    }

    static func makeModule(
        inputData: YandexAuthModuleInputData,
        moduleOutput: YandexAuthModuleOutput,
        view: PaymentMethodsViewController
    ) -> PaymentMethodsViewController {

        let presenter = YandexAuthPresenter(
            testModeSettings: inputData.testModeSettings
        )

        let authorizationService = AuthorizationProcessingAssembly
            .makeService(isLoggingEnabled: inputData.isLoggingEnabled,
                         testModeSettings: inputData.testModeSettings)
        let analyticsService = AnalyticsProcessingAssembly
            .makeAnalyticsService(isLoggingEnabled: inputData.isLoggingEnabled)
        let paymentService = PaymentProcessingAssembly
            .makeService(tokenizationSettings: inputData.tokenizationSettings,
                         testModeSettings: inputData.testModeSettings,
                         isLoggingEnabled: inputData.isLoggingEnabled)

        let interactor = YandexAuthInteractor(
            authorizationService: authorizationService,
            analyticsService: analyticsService,
            paymentService: paymentService,
            clientApplicationKey: inputData.clientApplicationKey,
            gatewayId: inputData.gatewayId,
            amount: inputData.amount,
            getSavePaymentMethod: inputData.getSavePaymentMethod
        )

        let router = YandexAuthRouter()

        view.output = presenter
        view.actionTextDialog.delegate = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.moduleOutput = moduleOutput
        presenter.router = router

        interactor.output = presenter

        router.transitionHandler = view

        return view
    }
}
