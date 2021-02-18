import UIKit

enum BankCardAssembly {
    static func makeModule(
        inputData: BankCardModuleInputData,
        moduleOutput: BankCardModuleOutput?
    ) -> UIViewController {
        let view = BankCardViewController()
        let presenter = BankCardPresenter.init(
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            priceViewModel: inputData.priceViewModel,
            feeViewModel: inputData.feeViewModel,
            termsOfService: inputData.termsOfService,
            cardScanning: inputData.cardScanning,
            savePaymentMethodViewModel: inputData.savePaymentMethodViewModel,
            initialSavePaymentMethod: inputData.initialSavePaymentMethod
        )

        let cardService = CardService()
        let bankSettingsService = BankSettingsServiceAssembly.makeService()
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsService = AnalyticsServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsProvider = AnalyticsProviderAssembly.makeProvider(
            testModeSettings: inputData.testModeSettings
        )
        let interactor = BankCardInteractor(
            cardService: cardService,
            bankSettingsService: bankSettingsService,
            paymentService: paymentService,
            analyticsService: analyticsService,
            analyticsProvider: analyticsProvider,
            clientApplicationKey: inputData.clientApplicationKey,
            amount: inputData.paymentOption.charge.plain,
            returnUrl: inputData.returnUrl
        )

        let router = BankCardRouter(
            cardScanner: inputData.cardScanning
        )

        view.output = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.moduleOutput = moduleOutput

        router.transitionHandler = view
        router.output = presenter

        interactor.output = presenter
        return view
    }
}
