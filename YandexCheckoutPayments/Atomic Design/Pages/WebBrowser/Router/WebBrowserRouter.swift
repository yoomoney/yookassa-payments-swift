class WebBrowserRouter {
    weak var transitionHandler: TransitionHandler?
}

// MARK: - WebBrowserRouterInput

extension WebBrowserRouter: WebBrowserRouterInput {
    func closeModule() {
        guard let transitionHandler = transitionHandler else { return }
        transitionHandler.dismiss(animated: true, completion: nil)
    }
}
