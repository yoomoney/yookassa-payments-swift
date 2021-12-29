import UIKit

enum YooMoneyAssembly {
    static func makeModule(
        inputData: YooMoneyModuleInputData,
        moduleOutput: YooMoneyModuleOutput?
    ) -> UIViewController {
        let view = YooMoneyViewController()

        let presenter = YooMoneyPresenter(
            clientApplicationKey: inputData.clientApplicationKey,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled,
            moneyAuthClientId: inputData.moneyAuthClientId,
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            price: inputData.price,
            fee: inputData.fee,
            paymentMethod: inputData.paymentMethod,
            paymentOption: inputData.paymentOption,
            termsOfService: inputData.termsOfService,
            returnUrl: inputData.returnUrl,
            savePaymentMethodViewModel: inputData.savePaymentMethodViewModel,
            tmxSessionId: inputData.tmxSessionId,
            initialSavePaymentMethod: inputData.initialSavePaymentMethod,
            isBackBarButtonHidden: inputData.isBackBarButtonHidden,
            isSafeDeal: inputData.isSafeDeal,
            paymentOptionTitle: inputData.paymentOptionTitle
        )

        let authorizationService = AuthorizationServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled,
            testModeSettings: inputData.testModeSettings,
            moneyAuthClientId: inputData.moneyAuthClientId
        )
        let analyticsService = AnalyticsTrackingAssembly.make(
            isLoggingEnabled: inputData.isLoggingEnabled
        )

        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let imageDownloadService = ImageDownloadServiceFactory.makeService()
        let threatMetrixService = ThreatMetrixServiceFactory.makeService()
        let interactor = YooMoneyInteractor(
            authorizationService: authorizationService,
            analyticsService: analyticsService,
            paymentService: paymentService,
            imageDownloadService: imageDownloadService,
            threatMetrixService: threatMetrixService,
            clientApplicationKey: inputData.clientApplicationKey,
            customerId: inputData.customerId
        )

        let router = YooMoneyRouter()

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
