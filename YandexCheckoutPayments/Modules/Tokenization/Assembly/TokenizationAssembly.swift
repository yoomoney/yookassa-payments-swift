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

        let viewController = TokenizationViewController()

        let presenter = TokenizationPresenter(inputData: inputData)
        let router = TokenizationRouter()
        let interactor = TokenizationInteractor(paymentService: paymentService,
                                                authorizationService: authorizationService,
                                                analyticsService: analyticsService,
                                                analyticsProvider: analyticsProvider,
                                                clientApplicationKey: inputData.clientApplicationKey,
                                                amount: inputData.amount)

        viewController.output = presenter
        viewController.transitioningDelegate = router
        viewController.modalPresentationStyle = .custom

        presenter.router = router
        presenter.interactor = interactor
        presenter.moduleOutput = moduleOutput
        presenter.view = viewController

        interactor.output = presenter

        router.transitionHandler = viewController

        return viewController
    }
}
