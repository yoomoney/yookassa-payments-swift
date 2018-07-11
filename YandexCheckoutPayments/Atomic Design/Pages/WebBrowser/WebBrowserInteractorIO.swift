import Foundation

protocol WebBrowserInteractorInput: class {
    func createRequest()
    func shouldProcessRequest(_ request: URLRequest) -> Bool
    func processRequest(_ request: URLRequest)
}

protocol WebBrowserInteractorOutput: class {
    func didCreateRequest(_ request: URLRequest, _ options: WebBrowserOptions)
    func failCreateRequest(with error: PresentableError)
}
