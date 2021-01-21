import YooMoneyCoreApi

class ApiLogger {}

// MARK: - Logger

extension ApiLogger: Logger {
    func log(message: String) {
        print(message)
    }
}
