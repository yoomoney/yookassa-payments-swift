protocol SberpayRouterInput: AnyObject {
    func presentTermsOfServiceModule(_ url: URL)
    func presentSafeDealInfo(title: String, body: String)
}
