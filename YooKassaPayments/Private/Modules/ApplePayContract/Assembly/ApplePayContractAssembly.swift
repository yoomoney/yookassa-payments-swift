import UIKit.UIViewController

enum ApplePayContractAssembly {
    static func makeModule(
        inputData: ApplePayContractModuleInputData,
        moduleOutput: ApplePayContractModuleOutput?
    ) -> UIViewController {
        let view = ApplePayContractViewController()

        let presenter = ApplePayContractPresenter(
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            price: inputData.price,
            fee: inputData.fee,
            paymentOption: inputData.paymentOption,
            termsOfService: inputData.termsOfService,
            merchantIdentifier: inputData.merchantIdentifier,
            savePaymentMethodViewModel: inputData.savePaymentMethodViewModel,
            initialSavePaymentMethod: inputData.initialSavePaymentMethod,
            isBackBarButtonHidden: inputData.isBackBarButtonHidden,
            isSafeDeal: inputData.isSafeDeal,
            paymentOptionTitle: inputData.paymentOptionTitle
        )

        let analyticsService = AnalyticsTrackingAssembly.make(isLoggingEnabled: inputData.isLoggingEnabled)
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let threatMetrixService = ThreatMetrixServiceFactory.makeService()
        let authService = AuthorizationServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled,
            testModeSettings: inputData.testModeSettings,
            moneyAuthClientId: nil
        )

        let interactor = ApplePayContractInteractor(
            paymentService: paymentService,
            analyticsService: analyticsService,
            authorizationService: authService,
            threatMetrixService: threatMetrixService,
            clientApplicationKey: inputData.clientApplicationKey,
            customerId: inputData.customerId
        )

        let router = ApplePayContractRouter()

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.moduleOutput = moduleOutput

        interactor.output = presenter

        view.output = presenter

        router.transitionHandler = view

        return view
    }
}
