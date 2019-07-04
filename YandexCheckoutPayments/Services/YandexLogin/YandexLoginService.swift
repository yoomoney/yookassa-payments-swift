import When
import YandexLoginSDK

/// Service for authorization with Yandex account
public final class YandexLoginService: YandexLoginProcessing, YandexLoginSdkProcessing {

    // MARK: - YandexLoginSdkProcessing

    /// Activates the Service. Should be called from applicationDidFinishLaunching.
    ///
    /// - Parameter appId: Application ID received on `https://oauth.yandex.ru`
    /// - Throws: Error if activation failed.
    public static func activate(withAppId appId: String) throws {
        try YXLSdk.shared.activate(withAppId: appId)
    }

    /// Should be called from `application(continue:restorationHandler:)`
    ///
    /// - Parameter userActivity: Parameter received from `application(continue:restorationHandler:)`
    public static func processUserActivity(_ userActivity: NSUserActivity) {
        YXLSdk.shared.processUserActivity(userActivity)
    }

    /// Should be called from `application(:open:options:)`
    ///
    /// - Parameters:
    ///   - url: Parameter received from `application(:open:options:)`
    ///   - sourceApplication: Parameter received from `application(:open:options:)`
    public static func handleOpen(_ url: URL, sourceApplication: String?) -> Bool {
        YandexLoginService.shared.shouldRejectAuthorization = false
        return YXLSdk.shared.handleOpen(url, sourceApplication: sourceApplication)
    }

    // MARK: - YandexLoginProcessing

    func authorize() -> Promise<YandexLoginResponse> {
        YandexLoginService.shared.shouldRejectAuthorization = true
        subscribeOnNotifications()

        let observer = Observer()
        self.observer = observer
        DispatchQueue.main.async {
            YXLSdk.shared.authorize()
        }
        return observer.promise
    }

    func logout() {
        YXLSdk.shared.logout()
    }

    // MARK: - Private

    private static var shared = YandexLoginService()

    private var shouldRejectAuthorization: Bool?

    private var observer: Observer? {
        didSet {
            oldValue?.promise.reject(YandexLoginProcessingError.wasCanceled)
            oldValue.map(YXLSdk.shared.remove)
            observer.map(YXLSdk.shared.add)
        }
    }

    private func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func applicationDidBecomeActive() {
        unsubscribeFromNotifications()
        if YandexLoginService.shared.shouldRejectAuthorization == true {
            observer?.promise.reject(YandexLoginProcessingError.applicationDidBecomeActive)
        }
    }

    private final class Observer: NSObject, YXLObserver {
        var promise = Promise<YandexLoginResponse>()

        func loginDidFinish(with result: YXLLoginResult) {
            promise.resolve(makeYandexLoginResponse(result))
        }

        func loginDidFinishWithError(_ error: Error) {
            promise.reject(makeError(error))
        }

        private func makeError(_ error: Error) -> YandexLoginProcessingError {
            let resultError: YandexLoginProcessingError

            if (error as NSError).code == YXLErrorCode.denied.rawValue {
                resultError = .accessDenied
            } else {
                resultError = .common(error)
            }

            return resultError
        }
    }
}

private func makeYandexLoginResponse(_ result: YXLLoginResult) -> YandexLoginResponse {
    return YandexLoginResponse(token: result.token, displayName: makeDisplayNameFromJwt(result.jwt))
}

// MARK: - Decoding JWT

private func makeDisplayNameFromJwt(_ jwt: String) -> String? {

    let requiredJwtCount = 3
    let payloadJwtFragment = 1
    let displayNameKey = "display_name"

    let components = jwt.components(separatedBy: ".")

    guard components.count == requiredJwtCount,
          let data = base64UrlDecode(components[payloadJwtFragment]),
          let json = try? JSONSerialization.jsonObject(with: data),
          let payloadJson = json as? [String: Any],
          let displayName = payloadJson[displayNameKey] as? String else {
        return nil
    }

    return displayName
}

private func base64UrlDecode(_ value: String) -> Data? {

    var base64 = value
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")

    let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
    let requiredLength = 4 * ceil(length / 4.0)
    let paddingLength = requiredLength - length

    if paddingLength > 0 {
        let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
        base64 += padding
    }

    return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
}
