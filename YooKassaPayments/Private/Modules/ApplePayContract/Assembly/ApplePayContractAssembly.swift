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
            isBackBarButtonHidden: inputData.isBackBarButtonHidden
        )

        let analyticsService = AnalyticsServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsProvider = AnalyticsProviderAssembly.makeProvider(
            testModeSettings: inputData.testModeSettings
        )
        let threatMetrixService = ThreatMetrixServiceFactory.makeService()
        let interactor = ApplePayContractInteractor(
            paymentService: paymentService,
            analyticsService: analyticsService,
            analyticsProvider: analyticsProvider,
            threatMetrixService: threatMetrixService,
            clientApplicationKey: inputData.clientApplicationKey
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
