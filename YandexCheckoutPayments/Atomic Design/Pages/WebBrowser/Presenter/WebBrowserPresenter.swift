import Dispatch
import FunctionalSwift
import UIKit

class WebBrowserPresenter: NSObject, WebBrowserViewOutput {
    var interactor: WebBrowserInteractorInput!
    var router: WebBrowserRouterInput!
    weak var view: WebBrowserViewInput?

    fileprivate let screenName: String?

    init(screenName: String? = nil) {
        self.screenName = screenName
    }

    func setupView() {
        view?.setScreenName(screenName)
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.interactor.createRequest()
        }
    }

    // MARK: - WebBrowserViewOutput

    func webView(_ webView: UIWebView,
                 shouldStartLoadWith request: URLRequest,
                 navigationType: UIWebViewNavigationType) -> Bool {
        let interactorShouldProcessRequest = interactor.shouldProcessRequest(request)
        if interactorShouldProcessRequest {
            interactor.processRequest(request)
        }
        return interactorShouldProcessRequest == false
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.showActivity()
        }
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self, let view = strongSelf.view else { return }
            view.updateToolBar()
            view.hideActivity()
        }
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.hideActivity()
        }
    }

    func didPressCloseButton() {
        router.closeModule()
    }
}

// MARK: - WebBrowserInteractorOutput

extension WebBrowserPresenter: WebBrowserInteractorOutput {
    func didCreateRequest(_ request: URLRequest, _ options: WebBrowserOptions = []) {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.showRequest(request)
            view.setupToolBar(options)
            view.setNavigationBar(options)
        }
    }

    func failCreateRequest(with error: PresentableError) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.present(error)
        }
    }
}
