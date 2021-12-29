import UIKit

enum BankCardAssembly {
    static func makeModule(
        inputData: BankCardModuleInputData,
        moduleOutput: BankCardModuleOutput?
    ) -> UIViewController {
        let view = makeView()
        let presenter = makePresenter(inputData: inputData)
        let interactor = makeInteractor(inputData: inputData)
        let router = makeRouter()

        let (
            bankCardDataInputView,
            bankCardDataInputModuleInput
        ) = makeBankCardDataInputView(
            inputData: inputData,
            moduleOutput: presenter,
            transitionHandler: view
        )

        view.output = presenter
        view.bankCardDataInputView = bankCardDataInputView

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.moduleOutput = moduleOutput
        presenter.bankCardDataInputModuleInput = bankCardDataInputModuleInput

        router.transitionHandler = view

        interactor.output = presenter
        return view
    }

    private static func makeView() -> BankCardViewController {
        let viewController = BankCardViewController()
        return viewController
    }

    private static func makePresenter(
        inputData: BankCardModuleInputData
    ) -> BankCardPresenter {
        let presenter = BankCardPresenter(
            cardService: CardService(),
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            priceViewModel: inputData.priceViewModel,
            feeViewModel: inputData.feeViewModel,
            termsOfService: inputData.termsOfService,
            cardScanning: inputData.cardScanning,
            isBackBarButtonHidden: inputData.isBackBarButtonHidden,
            instrument: inputData.instrument,
            canSaveInstrument: inputData.canSaveInstrument,
            apiSavePaymentMethod: inputData.apiSavePaymentMethod,
            clientSavePaymentMethod: inputData.savePaymentMethod,
            paymentMethodViewModelFactory: PaymentMethodViewModelFactoryAssembly.makeFactory(
                isLoggingEnabled: inputData.isLoggingEnabled
            ),
            isSafeDeal: inputData.isSafeDeal,
            config: inputData.config
        )
        return presenter
    }

    private static func makeInteractor(
        inputData: BankCardModuleInputData
    ) -> BankCardInteractor {
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsService = AnalyticsTrackingAssembly.make(isLoggingEnabled: inputData.isLoggingEnabled)
        let threatMetrixService = ThreatMetrixServiceFactory.makeService()
        let authService = AuthorizationServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled,
            testModeSettings: inputData.testModeSettings,
            moneyAuthClientId: nil
        )

        let interactor = BankCardInteractor(
            authService: authService,
            paymentService: paymentService,
            analyticsService: analyticsService,
            threatMetrixService: threatMetrixService,
            clientApplicationKey: inputData.clientApplicationKey,
            amount: inputData.paymentOption.charge.plain,
            returnUrl: inputData.returnUrl,
            customerId: inputData.customerId
        )
        return interactor
    }

    private static func makeRouter() -> BankCardRouter {
        let router = BankCardRouter()
        return router
    }

    private static func makeBankCardDataInputView(
        inputData: BankCardModuleInputData,
        moduleOutput: BankCardDataInputModuleOutput?,
        transitionHandler: TransitionHandler?
    ) -> (
        view: BankCardDataInputView,
        moduleInput: BankCardDataInputModuleInput
    ) {
        let inputPanPlaceholder = inputData.cardScanning != nil
            ? CommonLocalized.BankCardView.inputPanPlaceholder
            : CommonLocalized.BankCardView.inputPanPlaceholderWithoutScan

        let inputData = BankCardDataInputModuleInputData(
            inputPanHint: CommonLocalized.BankCardView.inputPanHint,
            inputPanPlaceholder: inputPanPlaceholder,
            inputExpiryDateHint: CommonLocalized.BankCardView.inputExpiryDateHint,
            inputExpiryDatePlaceholder: CommonLocalized.BankCardView.inputExpiryDatePlaceholder,
            inputCvcHint: CommonLocalized.BankCardView.inputCvcHint,
            inputCvcPlaceholder: CommonLocalized.BankCardView.inputCvcPlaceholder,
            cardScanner: inputData.cardScanning,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let (view, moduleInput) = BankCardDataInputAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput,
            transitionHandler: transitionHandler
        )
        return (view, moduleInput)
    }
}
