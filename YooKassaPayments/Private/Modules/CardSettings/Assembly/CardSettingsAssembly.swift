import UIKit

enum CardSettingsAssembly {
    static func make(data: CardSettingsModuleInputData, output: CardSettingsModuleOutput? = nil) -> UIViewController {
        let view = CardSettingsViewController(nibName: nil, bundle: nil)
        let presenter = CardSettingsPresenter(
            data: data,
            paymentMethodViewModelFactory: PaymentMethodViewModelFactoryAssembly.makeFactory()
        )
        let interactor = CardSettingsInteractor(
            clientId: data.clientId,
            paymentService: PaymentServiceAssembly.makeService(
                tokenizationSettings: data.tokenizationSettings,
                testModeSettings: data.testModeSettings,
                isLoggingEnabled: data.isLoggingEnabled
            ),
            analyticsService: AnalyticsServiceAssembly.makeService(isLoggingEnabled: data.isLoggingEnabled)
        )
        let router = CardSettingsRouter(transitionHandler: view)

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.output = output

        view.output = presenter
        interactor.output = presenter
        return view
    }
}
