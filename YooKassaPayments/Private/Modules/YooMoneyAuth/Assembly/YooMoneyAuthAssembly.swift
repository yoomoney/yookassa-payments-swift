import class UIKit.UIViewController

enum YooMoneyAuthAssembly {

    static func makeModule(
        inputData: YooMoneyAuthModuleInputData,
        moduleOutput: YooMoneyAuthModuleOutput
    ) -> PaymentMethodsViewController {
        let view = PaymentMethodsViewController()
        return YooMoneyAuthAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput,
            view: view
        )
    }

    static func makeModule(
        inputData: YooMoneyAuthModuleInputData,
        moduleOutput: YooMoneyAuthModuleOutput,
        view: PaymentMethodsViewController
    ) -> PaymentMethodsViewController {

        assert(inputData.moneyAuthClientId != nil, "`moneyAuthClientId` should be in `TokenizationModuleInputData`")

        let moneyAuthConfig = MoneyAuthAssembly.makeMoneyAuthConfig(
            moneyAuthClientId: inputData.moneyAuthClientId ?? "",
            loggingEnabled: inputData.isLoggingEnabled
        )

        let moneyAuthCustomization = MoneyAuthAssembly.makeMoneyAuthCustomization()

        let presenter = YooMoneyAuthPresenter(
            testModeSettings: inputData.testModeSettings,
            moneyAuthConfig: moneyAuthConfig,
            moneyAuthCustomization: moneyAuthCustomization,
            kassaPaymentsCustomization: inputData.kassaPaymentsCustomization,
            paymentMethodsModuleInput: inputData.paymentMethodsModuleInput
        )

        let authorizationService = AuthorizationProcessingAssembly
            .makeService(isLoggingEnabled: inputData.isLoggingEnabled,
                         testModeSettings: inputData.testModeSettings,
                         moneyAuthClientId: inputData.moneyAuthClientId)
        let analyticsService = AnalyticsProcessingAssembly
            .makeAnalyticsService(isLoggingEnabled: inputData.isLoggingEnabled)
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )

        let interactor = YooMoneyAuthInteractor(
            authorizationService: authorizationService,
            analyticsService: analyticsService,
            paymentService: paymentService,
            clientApplicationKey: inputData.clientApplicationKey,
            gatewayId: inputData.gatewayId,
            amount: inputData.amount,
            getSavePaymentMethod: inputData.getSavePaymentMethod
        )

        let router = YooMoneyAuthRouter()

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
