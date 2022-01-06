import MoneyAuth
import UIKit.UIViewController
import YooMoneyCoreApi

enum PaymentMethodsAssembly {
    static func makeModule(
        inputData: PaymentMethodsModuleInputData,
        tokenizationModuleOutput: TokenizationModuleOutput?
    ) -> (
        view: UIViewController,
        moduleInput: PaymentMethodsModuleInput
    ) {
        let view = PaymentMethodsViewController()

        let moneyAuthConfig = MoneyAuthAssembly.makeMoneyAuthConfig(
            moneyAuthClientId: inputData.moneyAuthClientId ?? "",
            loggingEnabled: inputData.isLoggingEnabled
        )

        let moneyAuthCustomization = MoneyAuthAssembly.makeMoneyAuthCustomization()

        let paymentMethodViewModelFactory = PaymentMethodViewModelFactoryAssembly.makeFactory(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let priceViewModelFactory = PriceViewModelFactoryAssembly.makeFactory()
        let presenter = PaymentMethodsPresenter(
            isLogoVisible: inputData.tokenizationSettings.showYooKassaLogo,
            paymentMethodViewModelFactory: paymentMethodViewModelFactory,
            applicationScheme: inputData.applicationScheme,
            priceViewModelFactory: priceViewModelFactory,
            clientApplicationKey: inputData.clientApplicationKey,
            applePayMerchantIdentifier: inputData.applePayMerchantIdentifier,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled,
            moneyAuthClientId: inputData.moneyAuthClientId,
            tokenizationSettings: inputData.tokenizationSettings,
            moneyAuthConfig: moneyAuthConfig,
            moneyAuthCustomization: moneyAuthCustomization,
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            returnUrl: inputData.returnUrl,
            savePaymentMethod: inputData.savePaymentMethod,
            userPhoneNumber: inputData.userPhoneNumber,
            cardScanning: inputData.cardScanning,
            customerId: inputData.customerId,
            config: inputData.config
        )

        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let authorizationService = AuthorizationServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled,
            testModeSettings: inputData.testModeSettings,
            moneyAuthClientId: inputData.moneyAuthClientId
        )
        let analyticsService = AnalyticsTrackingAssembly.make(isLoggingEnabled: inputData.isLoggingEnabled)
        let accountService = AccountServiceFactory.makeService(
            config: moneyAuthConfig
        )
        let threatMetrixService = ThreatMetrixServiceFactory.makeService()
        let amountNumberFormatter = AmountNumberFormatterAssembly.makeAmountNumberFormatter()
        let appDataTransferMediator = AppDataTransferMediatorFactory.makeMediator(
            config: moneyAuthConfig
        )

        let interactor = PaymentMethodsInteractor(
            paymentService: paymentService,
            authorizationService: authorizationService,
            analyticsService: analyticsService,
            accountService: accountService,
            threatMetrixService: threatMetrixService,
            amountNumberFormatter: amountNumberFormatter,
            appDataTransferMediator: appDataTransferMediator,
            configMediator: ConfigMediatorAssembly.make(isLoggingEnabled: inputData.isLoggingEnabled),
            clientApplicationKey: inputData.clientApplicationKey,
            gatewayId: inputData.gatewayId,
            amount: inputData.amount,
            getSavePaymentMethod: inputData.getSavePaymentMethod,
            customerId: inputData.customerId
        )

        let router = PaymentMethodsRouter()

        presenter.tokenizationModuleOutput = tokenizationModuleOutput
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        interactor.output = presenter

        view.output = presenter

        router.transitionHandler = view

        return (view: view, moduleInput: presenter)
    }
}
