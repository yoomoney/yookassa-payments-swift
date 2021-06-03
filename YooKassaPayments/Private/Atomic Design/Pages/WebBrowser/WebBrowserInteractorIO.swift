protocol WebBrowserInteractorInput: AnyObject {
    func createRequest()
    func shouldProcessRequest(_ request: URLRequest) -> Bool
    func processRequest(_ request: URLRequest)
}

protocol WebBrowserInteractorOutput: AnyObject {
    func didCreateRequest(_ request: URLRequest, _ options: WebBrowserOptions)
    func failCreateRequest(with error: PresentableError)
}
