import UIKit.UIViewController
import YandexMoneyCoreApi

enum PaymentMethodsAssembly {

    static func makeModule(inputData: PaymentMethodsModuleInputData,
                           moduleOutput: PaymentMethodsModuleOutput?) -> UIViewController {
        let view = PaymentMethodsViewController()
        return PaymentMethodsAssembly.makeModule(inputData: inputData,
                                                 moduleOutput: moduleOutput,
                                                 view: view)
    }

    static func makeModule(inputData: PaymentMethodsModuleInputData,
                           moduleOutput: PaymentMethodsModuleOutput?,
                           view: PaymentMethodsViewController) -> PaymentMethodsViewController {

        let presenter = PaymentMethodsPresenter(isLogoVisible: inputData.tokenizationSettings.showYandexCheckoutLogo)

        let paymentService = PaymentProcessingAssembly.makeService(tokenizationSettings: inputData.tokenizationSettings,
                                                                   testModeSettings: inputData.testModeSettings)
        let authorizationService
            = AuthorizationProcessingAssembly.makeService(testModeSettings: inputData.testModeSettings)
        let analyticsService = AnalyticsProcessingAssembly.makeAnalyticsService()
        let analyticsProvider = AnalyticsProvider(authorizationService: authorizationService)

        let interactor = PaymentMethodsInteractor(paymentService: paymentService,
                                                  authorizationService: authorizationService,
                                                  analyticsService: analyticsService,
                                                  analyticsProvider: analyticsProvider,
                                                  clientApplicationKey: inputData.clientApplicationKey,
                                                  gatewayId: inputData.gatewayId,
                                                  amount: inputData.amount)

        presenter.moduleOutput = moduleOutput
        presenter.view = view
        presenter.interactor = interactor

        interactor.output = presenter

        view.output = presenter
        view.actionTextDialog.delegate = presenter

        return view
    }
}
