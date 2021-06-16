import UIKit

enum BankCardDataInputAssembly {
    static func makeModule(
        inputData: BankCardDataInputModuleInputData,
        moduleOutput: BankCardDataInputModuleOutput?,
        transitionHandler: TransitionHandler?
    ) -> (
        view: BankCardDataInputView,
        moduleInput: BankCardDataInputModuleInput
    ) {
        let view = makeView(inputData: inputData)
        let presenter = makePresenter(inputData: inputData)
        let interactor = makeInteractor(inputData: inputData)
        let router = makeRouter(inputData: inputData)

        view.output = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.moduleOutput = moduleOutput
        presenter.router = router

        interactor.output = presenter

        router.output = presenter
        router.transitionHandler = transitionHandler

        return (view, presenter)
    }

    private static func makeView(
        inputData: BankCardDataInputModuleInputData
    ) -> BankCardDataInputView {
        let view = BankCardDataInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyles(
            UIView.Styles.grayBackground
        )
        return view
    }

    private static func makePresenter(
        inputData: BankCardDataInputModuleInputData
    ) -> BankCardDataInputPresenter {
        let bankCardImageFactory = BankCardImageFactoryAssembly.makeFactory()
        let presenter = BankCardDataInputPresenter(
            inputPanHint: inputData.inputPanHint,
            inputPanPlaceholder: inputData.inputPanPlaceholder,
            inputExpiryDateHint: inputData.inputExpiryDateHint,
            inputExpiryDatePlaceholder: inputData.inputExpiryDatePlaceholder,
            inputCvcHint: inputData.inputCvcHint,
            inputCvcPlaceholder: inputData.inputCvcPlaceholder,
            cardScanner: inputData.cardScanner,
            bankCardImageFactory: bankCardImageFactory
        )
        return presenter
    }

    private static func makeInteractor(
        inputData: BankCardDataInputModuleInputData
    ) -> BankCardDataInputInteractor {
        let cardService = CardService()
        let bankSettingsService = BankSettingsServiceAssembly.makeService()
        let analyticsService = AnalyticsServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let interactor = BankCardDataInputInteractor(
            cardService: cardService,
            bankSettingsService: bankSettingsService,
            analyticsService: analyticsService
        )
        return interactor
    }

    private static func makeRouter(
        inputData: BankCardDataInputModuleInputData
    ) -> BankCardDataInputRouter {
        let router = BankCardDataInputRouter(
            cardScanner: inputData.cardScanner
        )
        return router
    }
}
