import UIKit.UIViewController

enum CardSecAssembly {
    static func makeModule(inputData: CardSecModuleInputData,
                           moduleOutput: CardSecModuleOutput) -> UIViewController {
        let presenter = CardSecPresenter()

        let analyticsService = AnalyticsProcessingAssembly.makeAnalyticsService()
        let interactor = CardSecInteractor(analyticsService: analyticsService,
                                           requestUrl: inputData.requestUrl,
                                           redirectUrl: inputData.redirectUrl)

        presenter.cardSecInteractor = interactor
        presenter.cardSecModuleOutput = moduleOutput

        interactor.output = presenter
        interactor.cardSecPresenter = presenter

        return WebBrowserAssembly.makeModule(presenter: presenter,
                                             interactor: interactor)
    }
}
