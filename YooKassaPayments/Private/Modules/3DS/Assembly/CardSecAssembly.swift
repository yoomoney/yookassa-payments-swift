import UIKit.UIViewController

enum CardSecAssembly {
    static func makeModule(
        inputData: CardSecModuleInputData,
        moduleOutput: CardSecModuleOutput
    ) -> UIViewController {
        let presenter = CardSecPresenter()

        let analyticsService = AnalyticsServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let logger = WebLoggerServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let interactor = CardSecInteractor(
            analyticsService: analyticsService,
            requestUrl: inputData.requestUrl,
            redirectUrl: inputData.redirectUrl,
            logger: logger
        )

        presenter.cardSecInteractor = interactor
        presenter.cardSecModuleOutput = moduleOutput

        interactor.output = presenter
        interactor.cardSecPresenter = presenter

        return WebBrowserAssembly.makeModule(
            presenter: presenter,
            interactor: interactor
        )
    }
}
