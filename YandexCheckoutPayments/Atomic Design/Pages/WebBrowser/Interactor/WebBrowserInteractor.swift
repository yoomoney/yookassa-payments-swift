import Foundation

final class WebBrowserInteractor {

    // MARK: - VIPER properties

    weak var output: WebBrowserInteractorOutput?

    // MARK: - Initialization

    private let url: URL

    init(url: URL) {
        self.url = url
    }
}

// MARK: - WebBrowserInteractorInput

extension WebBrowserInteractor: WebBrowserInteractorInput {

    func createRequest() {
        guard let output = output else { return }
        let request = URLRequest(url: url)
        output.didCreateRequest(request, .all)
    }

    func shouldProcessRequest(_ request: URLRequest) -> Bool {
        return false
    }

    func processRequest(_ request: URLRequest) {}
}
