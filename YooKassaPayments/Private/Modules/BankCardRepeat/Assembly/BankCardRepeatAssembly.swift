import UIKit

enum BankCardRepeatAssembly {
    static func makeModule(
        inputData: BankCardRepeatModuleInputData,
        moduleOutput: TokenizationModuleOutput?
    ) -> (
        view: UIViewController,
        moduleInput: BankCardRepeatModuleInput
    ) {
        let view = BankCardRepeatViewController()

        let cardService = CardService()
        let paymentMethodViewModelFactory = PaymentMethodViewModelFactoryAssembly.makeFactory()
        let priceViewModelFactory = PriceViewModelFactoryAssembly.makeFactory()
        let termsOfService = TermsOfServiceFactory.makeTermsOfService()
        let initialSavePaymentMethod = makeInitialSavePaymentMethod(inputData.savePaymentMethod)
        let savePaymentMethodViewModel = SavePaymentMethodViewModelFactory.makeSavePaymentMethodViewModel(
            inputData.savePaymentMethod,
            initialState: initialSavePaymentMethod
        )
        let presenter = BankCardRepeatPresenter(
            cardService: cardService,
            paymentMethodViewModelFactory: paymentMethodViewModelFactory,
            priceViewModelFactory: priceViewModelFactory,
            isLoggingEnabled: inputData.isLoggingEnabled,
            returnUrl: inputData.returnUrl,
            paymentMethodId: inputData.paymentMethodId,
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            termsOfService: termsOfService,
            savePaymentMethodViewModel: savePaymentMethodViewModel,
            initialSavePaymentMethod: initialSavePaymentMethod,
            isSafeDeal: inputData.isSafeDeal
        )

        let analyticsService = AnalyticsServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: TokenizationSettings(),
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsProvider = AnalyticsProviderAssembly.makeProvider(
            testModeSettings: inputData.testModeSettings
        )
        let threatMetrixService = ThreatMetrixServiceFactory.makeService()
        let amountNumberFormatter = AmountNumberFormatterAssembly.makeAmountNumberFormatter()
        let interactor = BankCardRepeatInteractor(
            analyticsService: analyticsService,
            analyticsProvider: analyticsProvider,
            paymentService: paymentService,
            threatMetrixService: threatMetrixService,
            amountNumberFormatter: amountNumberFormatter,
            clientApplicationKey: inputData.clientApplicationKey,
            gatewayId: inputData.gatewayId,
            amount: inputData.amount,
            customerId: inputData.customerId
        )

        let router = BankCardRepeatRouter()

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.moduleOutput = moduleOutput

        interactor.output = presenter

        view.output = presenter

        router.transitionHandler = view

        return (view: view, moduleInput: presenter)

    }
}

// MARK: - Private global helpers

private func makeInitialSavePaymentMethod(
    _ savePaymentMethod: SavePaymentMethod
) -> Bool {
    let initialSavePaymentMethod: Bool
    switch savePaymentMethod {
    case .on:
        initialSavePaymentMethod = true
    case .off, .userSelects:
        initialSavePaymentMethod = false
    }
    return initialSavePaymentMethod
}
