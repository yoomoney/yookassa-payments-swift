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
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            priceViewModel: inputData.priceViewModel,
            feeViewModel: inputData.feeViewModel,
            termsOfService: inputData.termsOfService,
            cardScanning: inputData.cardScanning,
            savePaymentMethodViewModel: inputData.savePaymentMethodViewModel,
            initialSavePaymentMethod: inputData.initialSavePaymentMethod,
            isBackBarButtonHidden: inputData.isBackBarButtonHidden
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
        let analyticsService = AnalyticsServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsProvider = AnalyticsProviderAssembly.makeProvider(
            testModeSettings: inputData.testModeSettings
        )
        let threatMetrixService = ThreatMetrixServiceFactory.makeService()
        let interactor = BankCardInteractor(
            paymentService: paymentService,
            analyticsService: analyticsService,
            analyticsProvider: analyticsProvider,
            threatMetrixService: threatMetrixService,
            clientApplicationKey: inputData.clientApplicationKey,
            amount: inputData.paymentOption.charge.plain,
            returnUrl: inputData.returnUrl
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
        let inputData = BankCardDataInputModuleInputData(
            inputPanHint: §Localized.BankCardView.inputPanHint,
            inputPanPlaceholder: §Localized.BankCardView.inputPanPlaceholder,
            inputExpiryDateHint: §Localized.BankCardView.inputExpiryDateHint,
            inputExpiryDatePlaceholder: §Localized.BankCardView.inputExpiryDatePlaceholder,
            inputCvcHint: §Localized.BankCardView.inputCvcHint,
            inputCvcPlaceholder: §Localized.BankCardView.inputCvcPlaceholder,
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

// MARK: - Localized

private extension BankCardAssembly {
    enum Localized {
        enum BankCardView: String {
            case inputPanHint = "BankCardView.inputPanHint"
            case inputPanPlaceholder = "BankCardView.inputPanPlaceholder"
            case inputExpiryDateHint = "BankCardView.inputExpiryDateHint"
            case inputExpiryDatePlaceholder = "BankCardView.inputExpiryDatePlaceholder"
            case inputCvcHint = "BankCardView.inputCvcHint"
            case inputCvcPlaceholder = "BankCardView.inputCvcPlaceholder"
        }
    }
}
