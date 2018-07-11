import UIKit.UIViewController
import YandexCheckoutPaymentsApi

/// Tokenization module builder.
public enum TokenizationAssembly {

    /// Creates tokenization view controller.
    ///
    /// - Returns: Tokenization view controller which implements the protocol `TokenizationModuleInput`.
    public static func makeModule(inputData: TokenizationModuleInputData,
                                  moduleOutput: TokenizationModuleOutput)
            -> UIViewController & TokenizationModuleInput {
        let paymentService = PaymentProcessingAssembly.makeService(tokenizationSettings: inputData.tokenizationSettings,
                                                                   testModeSettings: inputData.testModeSettings)
        let authorizationService
            = AuthorizationProcessingAssembly.makeService(testModeSettings: inputData.testModeSettings)

        let analyticsService = AnalyticsProcessingAssembly.makeAnalyticsService()
        let analyticsProvider = AnalyticsProvider(authorizationService: authorizationService)

        let viewController = TokenizationViewController()

        let presenter = TokenizationPresenter(inputData: inputData)
        let router = TokenizationRouter()
        let interactor = TokenizationInteractor(paymentService: paymentService,
                                                authorizationService: authorizationService,
                                                analyticsService: analyticsService,
                                                analyticsProvider: analyticsProvider,
                                                clientApplicationKey: inputData.clientApplicationKey,
                                                amount: inputData.amount)

        let paymentMethodsModuleInputData
            = PaymentMethodsModuleInputData(clientApplicationKey: inputData.clientApplicationKey,
                                            gatewayId: inputData.gatewayId,
                                            amount: inputData.amount,
                                            tokenizationSettings: inputData.tokenizationSettings,
                                            testModeSettings: inputData.testModeSettings)

        let paymentMethods = PaymentMethodsAssembly.makeModule(inputData: paymentMethodsModuleInputData,
                                                               moduleOutput: presenter)

        viewController.output = presenter
        viewController.transitioningDelegate = router
        viewController.modalPresentationStyle = .custom

        presenter.router = router
        presenter.interactor = interactor
        presenter.moduleOutput = moduleOutput

        interactor.output = presenter

        router.transitionHandler = viewController

        viewController.show(paymentMethods, sender: nil)

        return viewController
    }
}
