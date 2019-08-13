import Foundation

enum WebLoggerAssembly {
    static func makeLogger(isLoggingEnabled: Bool) -> WebLogger {
        return WebLogger(isLoggingEnabled: isLoggingEnabled)
    }
}

final class WebLogger {

    private let isLoggingEnabled: Bool

    init(isLoggingEnabled: Bool) {
        self.isLoggingEnabled = isLoggingEnabled
    }

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
