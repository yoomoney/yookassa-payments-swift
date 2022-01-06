import UIKit

enum SberpayAssembly {
    static func makeModule(
        inputData: SberpayModuleInputData,
        moduleOutput: SberpayModuleOutput?
    ) -> UIViewController {
        let view = SberpayViewController()

        let presenter = SberpayPresenter(
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            priceViewModel: inputData.priceViewModel,
            feeViewModel: inputData.feeViewModel,
            termsOfService: inputData.termsOfService,
            isBackBarButtonHidden: inputData.isBackBarButtonHidden,
            isSafeDeal: inputData.isSafeDeal,
            clientSavePaymentMethod: inputData.clientSavePaymentMethod,
            isSavePaymentMethodAllowed: inputData.paymentOption.savePaymentMethod == .allowed,
            config: inputData.config
        )
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsService = AnalyticsTrackingAssembly.make(isLoggingEnabled: inputData.isLoggingEnabled)
        let threatMetrixService = ThreatMetrixServiceFactory.makeService()
        let authorizationService = AuthorizationServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled,
            testModeSettings: inputData.testModeSettings,
            moneyAuthClientId: nil
        )

        let interactor = SberpayInteractor(
            authService: authorizationService,
            paymentService: paymentService,
            analyticsService: analyticsService,
            threatMetrixService: threatMetrixService,
            clientApplicationKey: inputData.clientApplicationKey,
            amount: inputData.paymentOption.charge.plain,
            returnUrl: inputData.returnUrl,
            customerId: inputData.customerId
        )
        let router = SberpayRouter()

        view.output = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.moduleOutput = moduleOutput

        interactor.output = presenter

        router.transitionHandler = view

        return view
    }
}
