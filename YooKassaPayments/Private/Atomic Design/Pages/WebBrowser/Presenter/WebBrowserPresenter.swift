import Dispatch
import UIKit
import WebKit.WKNavigationDelegate
import WebKit.WKUIDelegate

class WebBrowserPresenter: NSObject, WebBrowserViewOutput {

    // MARK: - Viper

    var interactor: WebBrowserInteractorInput!
    var router: WebBrowserRouterInput!
    weak var view: WebBrowserViewInput?

    // MARK: - Init data

    fileprivate let screenName: String?

    // MARK: - Init

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

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.showActivity()
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self, let view = strongSelf.view else { return }
            view.updateToolBar()
            view.hideActivity()
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.hideActivity()
        }
    }

    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {

        DispatchQueue.main.async { [weak self] in
            self?.view?.hideActivity()
        }
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {

        let request = navigationAction.request
        let interactorShouldProcessRequest = interactor.shouldProcessRequest(request)
        if interactorShouldProcessRequest {
            interactor.processRequest(request)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if (navigationAction.targetFrame?.isMainFrame ?? false) == false {
            webView.load(navigationAction.request)
        }
        return nil
    }

    func didPressCloseButton() {
        router.closeModule()
    }
}

// MARK: - WebBrowserInteractorOutput

extension WebBrowserPresenter: WebBrowserInteractorOutput {
    func didCreateRequest(
        _ request: URLRequest,
        _ options: WebBrowserOptions = []
    ) {
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
