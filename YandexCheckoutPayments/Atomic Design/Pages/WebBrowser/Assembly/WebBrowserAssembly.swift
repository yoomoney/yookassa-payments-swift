import UIKit

class WebBrowserAssembly {
    static func makeModule(presenter: WebBrowserPresenter,
                           interactor: WebBrowserInteractorInput) -> UIViewController {
        let router = WebBrowserRouter()
        let viewController = WebBrowserViewController()
        viewController.output = presenter

        presenter.view = viewController
        presenter.interactor = interactor
        presenter.router = router
        router.transitionHandler = viewController

        return viewController
    }
}
