import YooMoneyCoreApi

class ApiLogger {}

// MARK: - Logger

extension ApiLogger: YooMoneyCoreApi.Logger {
    func log(message: String) {
        print(message)
    }
}
