import class UIKit.UIViewController

enum YandexAuthAssembly {

    static func makeModule(inputData: YandexAuthModuleInputData,
                           moduleOutput: YandexAuthModuleOutput) -> PaymentMethodsViewController {
        let view = PaymentMethodsViewController()
        return YandexAuthAssembly.makeModule(inputData: inputData,
                                      moduleOutput: moduleOutput,
                                      view: view)
    }

    static func makeModule(inputData: YandexAuthModuleInputData,
                           moduleOutput: YandexAuthModuleOutput,
                           view: PaymentMethodsViewController) -> PaymentMethodsViewController {

        let presenter = YandexAuthPresenter()

        let authorizationService
            = AuthorizationProcessingAssembly.makeService(testModeSettings: inputData.testModeSettings)
        let analyticsService = AnalyticsProcessingAssembly.makeAnalyticsService()
        let paymentService = PaymentProcessingAssembly.makeService(tokenizationSettings: inputData.tokenizationSettings,
                                                                   testModeSettings: inputData.testModeSettings)

        let interactor = YandexAuthInteractor(authorizationService: authorizationService,
                                              analyticsService: analyticsService,
                                              paymentService: paymentService,
                                              clientApplicationKey: inputData.clientApplicationKey,
                                              gatewayId: inputData.gatewayId,
                                              amount: inputData.amount)

        view.output = presenter
        view.actionTextDialog.delegate = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.moduleOutput = moduleOutput

        interactor.output = presenter

        return view
    }
}
