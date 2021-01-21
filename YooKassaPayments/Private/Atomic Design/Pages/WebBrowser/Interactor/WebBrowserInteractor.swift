import Foundation

final class WebBrowserInteractor {

    // MARK: - VIPER

    weak var output: WebBrowserInteractorOutput?

    // MARK: - Init data

    private let url: URL

    // MARK: - Init

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
