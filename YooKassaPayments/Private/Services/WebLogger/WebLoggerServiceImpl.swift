final class WebLoggerServiceImpl {

    // MARK: - Init data

    private let isLoggingEnabled: Bool

    // MARK: - Init

    init(isLoggingEnabled: Bool) {
        self.isLoggingEnabled = isLoggingEnabled
    }
}

// MARK: - WebLoggerService

extension WebLoggerServiceImpl: WebLoggerService {
    func trace(_ request: URLRequest) {
        guard isLoggingEnabled else { return }
        let path = request.url?.absoluteString ?? ""
        let message = [
            "\(Date()): {",
            "\n",
            "\turl: \"\(path)\"",
            "\n",
            "}",
        ].joined()
        print(message)
    }
}
