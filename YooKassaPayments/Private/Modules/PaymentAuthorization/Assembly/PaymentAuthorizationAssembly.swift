import UIKit

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
        let analyticsService = AnalyticsTrackingAssembly.make(isLoggingEnabled: inputData.isLoggingEnabled)
        let interactor = PaymentAuthorizationInteractor(
            authorizationService: authorizationService,
            analyticsService: analyticsService,
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
