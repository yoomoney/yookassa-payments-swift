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
            isBackBarButtonHidden: inputData.isBackBarButtonHidden
        )
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsProvider = AnalyticsProviderAssembly.makeProvider(
            testModeSettings: inputData.testModeSettings
        )
        let analyticsService = AnalyticsServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let interactor = SberpayInteractor(
            paymentService: paymentService,
            analyticsProvider: analyticsProvider,
            analyticsService: analyticsService,
            clientApplicationKey: inputData.clientApplicationKey,
            amount: inputData.paymentOption.charge.plain,
            returnUrl: inputData.returnUrl
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
