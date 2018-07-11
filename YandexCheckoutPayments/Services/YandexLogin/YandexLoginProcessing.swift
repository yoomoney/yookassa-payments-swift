import class Foundation.NSUserActivity
import struct Foundation.URL
import class When.Promise

struct YandexLoginResponse {
    let token: String
    let displayName: String?
}

enum YandexLoginProcessingError: Error {
    case common(Error)
    case wasCanceled
    case accessDenied
    case applicationDidBecomeActive
}

protocol YandexLoginSdkProcessing {
    static func activate(withAppId appId: String) throws
    static func processUserActivity(_ userActivity: NSUserActivity)
    static func handleOpen(_ url: URL, sourceApplication: String?) -> Bool
}

protocol YandexLoginProcessing {
    func authorize() -> Promise<YandexLoginResponse>
    func logout()
}
