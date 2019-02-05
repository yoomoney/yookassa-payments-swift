import UIKit.UIViewController
import YandexMoneyCoreApi

enum PaymentMethodsAssembly {

    static func makeModule(inputData: PaymentMethodsModuleInputData,
                           moduleOutput: PaymentMethodsModuleOutput?) -> UIViewController {
        let (view, _) = PaymentMethodsAssembly.makeModule(inputData: inputData,
                                                          moduleOutput: moduleOutput,
                                                          view: PaymentMethodsViewController())
        return view
    }

    static func makeModule(inputData: PaymentMethodsModuleInputData,
                           moduleOutput: PaymentMethodsModuleOutput?,
                           view: PaymentMethodsViewController) -> (view: PaymentMethodsViewController,
                                                                   moduleInput: PaymentMethodsModuleInput) {

        let presenter = PaymentMethodsPresenter(isLogoVisible: inputData.tokenizationSettings.showYandexCheckoutLogo)

        let paymentService = PaymentProcessingAssembly
            .makeService(tokenizationSettings: inputData.tokenizationSettings,
                         testModeSettings: inputData.testModeSettings,
                         isLoggingEnabled: inputData.isLoggingEnabled)
        let authorizationService = AuthorizationProcessingAssembly
            .makeService(isLoggingEnabled: inputData.isLoggingEnabled,
                         testModeSettings: inputData.testModeSettings)
        let analyticsService = AnalyticsProcessingAssembly
            .makeAnalyticsService(isLoggingEnabled: inputData.isLoggingEnabled)
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

        return (view: view, moduleInput: presenter)
    }
}
