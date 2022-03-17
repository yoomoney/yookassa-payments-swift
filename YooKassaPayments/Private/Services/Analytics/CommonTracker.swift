import Foundation
import YandexMobileMetrica
class CommonTracker: AnalyticsTracking {
    // MARK: - Properties

    #if DEBUG
    private let yandexMetricaKey = "fdeb958c-8bfd-4dab-98df-f9be4bdb6646"
    #else
    private let yandexMetricaKey = "b1ddbdc0-dca6-489c-a205-f71e0158bfcb"
    #endif

    private lazy var yandexMetrica = YMMYandexMetrica.reporter(forApiKey: yandexMetricaKey)

    private let isLoggingEnabled: Bool

    init(isLoggingEnabled: Bool) {
        self.isLoggingEnabled = isLoggingEnabled
    }

    func track(name: String, parameters: [String: String]?) {
        yandexMetrica?.reportEvent(name, parameters: parameters)

        if isLoggingEnabled {
            #if DEBUG
            let paraString = parameters.map { ", parameters: \($0)" } ?? ""
            print("!YMMYandexMetrica report event. name: \(name)" + paraString)
            #endif
        }
    }

    func track(event: AnalyticsEvent) {
        track(name: event.name, parameters: event.parameters(context: YKSdk.shared.analyticsContext))
    }

    func resume() {
        yandexMetrica?.resumeSession()
    }

    func pause() {
        yandexMetrica?.pauseSession()
    }
}
