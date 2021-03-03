import YandexMobileMetrica

final class AnalyticsServiceImpl {

    // MARK: - Init data

    private let isLoggingEnabled: Bool

    // MARK: - Init

    init(isLoggingEnabled: Bool) {
        self.isLoggingEnabled = isLoggingEnabled
    }

    // MARK: - Properties

    #if DEBUG
    private let yandexMetricaKey = "fdeb958c-8bfd-4dab-98df-f9be4bdb6646"
    #else
    private let yandexMetricaKey = "b1ddbdc0-dca6-489c-a205-f71e0158bfcb"
    #endif

    private lazy var reporter = YMMYandexMetrica.reporter(forApiKey: yandexMetricaKey)
}

// MARK: - AnalyticsService

extension AnalyticsServiceImpl: AnalyticsService {
    func start() {
        reporter?.resumeSession()
    }

    func stop() {
        reporter?.pauseSession()
    }

    func trackEvent(_ event: AnalyticsEvent) {
        let eventName = makeAnalyticsEventName(event)
        let parameters = makeAnalyticsParameters(event)
        trackEventNamed(eventName, parameters: parameters)
    }

    private func trackEventNamed(
        _ name: String,
        parameters: [String: String]?
    ) {
        logAnalyticsEventNamed(
            name,
            parameters: parameters,
            isLoggingEnabled: isLoggingEnabled
        )
        reporter?.reportEvent(
            name,
            parameters: parameters
        )
    }

    // swiftlint:disable cyclomatic_complexity
    private func makeAnalyticsEventName(
        _ event: AnalyticsEvent
    ) -> String {
        let eventName: String

        switch event {
        case .screenPaymentOptions:
            eventName = EventKey.screenPaymentOptions.rawValue

        case .screenPaymentContract:
            eventName = EventKey.screenPaymentContract.rawValue

        case .screenLinkedCardForm:
            eventName = EventKey.screenLinkedCardForm.rawValue

        case .screenBankCardForm:
            eventName = EventKey.screenBankCardForm.rawValue

        case .screenError:
            eventName = EventKey.screenError.rawValue

        case .screen3ds:
            eventName = EventKey.screen3ds.rawValue

        case .screenRecurringCardForm:
            eventName = EventKey.screenRecurringCardForm.rawValue

        case .actionTokenize:
            eventName = EventKey.actionTokenize.rawValue

        case .actionPaymentAuthorization:
            eventName = EventKey.actionPaymentAuthorization.rawValue

        case .actionLogout:
            eventName = EventKey.actionLogout.rawValue

        case .actionAuthWithoutWallet:
            eventName = EventKey.actionAuthWithoutWallet.rawValue

        case .userStartAuthorization:
            eventName = EventKey.userStartAuthorization.rawValue

        case .userCancelAuthorization:
            eventName = EventKey.userCancelAuthorization.rawValue

        case .userSuccessAuthorization:
            eventName = EventKey.userSuccessAuthorization.rawValue

        case .userFailedAuthorization:
            eventName = EventKey.userFailedAuthorization.rawValue

        case .actionBankCardForm:
            eventName = EventKey.actionBankCardForm.rawValue
        }
        return eventName
    }
    // swiftlint:enable cyclomatic_complexity

    // swiftlint:disable cyclomatic_complexity
    private func makeAnalyticsParameters(
        _ event: AnalyticsEvent
    ) -> [String: String]? {
        var parameters: [String: String]?

        switch event {
        case let .screenPaymentOptions(authType, sdkVersion):
            parameters = [
                authType.key: authType.rawValue,
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]

        case let .screenPaymentContract(authType, scheme, sdkVersion):
            parameters = [
                authType.key: authType.rawValue,
                scheme.key: scheme.rawValue,
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]

        case let .screenLinkedCardForm(sdkVersion):
            parameters = [
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]

        case let .screenBankCardForm(authType, sdkVersion):
            parameters = [
                authType.key: authType.rawValue,
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]

        case let .screenError(authType, scheme, sdkVersion):
            parameters = [
                authType.key: authType.rawValue,
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]
            if let scheme = scheme {
                parameters?[scheme.key] = scheme.rawValue
            }

        case let .screen3ds(sdkVersion):
            parameters = [
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]

        case let .screenRecurringCardForm(sdkVersion):
            parameters = [
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]

        case let .actionTokenize(scheme, authType, tokenType, sdkVersion):
            parameters = [
                scheme.key: scheme.rawValue,
                authType.key: authType.rawValue,
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]
            if let tokenType = tokenType {
                parameters?[tokenType.key] = tokenType.rawValue
            }

        case let .actionPaymentAuthorization(authPaymentStatus, sdkVersion):
            parameters = [
                authPaymentStatus.key: authPaymentStatus.rawValue,
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]

        case let .actionLogout(sdkVersion):
            parameters = [
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]

        case let .actionAuthWithoutWallet(sdkVersion):
            parameters = [
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]

        case let .userStartAuthorization(sdkVersion):
            parameters = [
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]

        case let .userCancelAuthorization(sdkVersion):
            parameters = [
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]

        case let .userSuccessAuthorization(moneyAuthProcessType, sdkVersion):
            parameters = [
                moneyAuthProcessType.key: moneyAuthProcessType.rawValue,
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]

        case let .userFailedAuthorization(errorLocalizedDescription, sdkVersion):
            parameters = [
                AnalyticsEvent.Keys.error.rawValue: errorLocalizedDescription,
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]

        case let .actionBankCardForm(action, sdkVersion):
            parameters = [
                action.key: action.rawValue,
                AnalyticsEvent.Keys.msdkVersion.rawValue: sdkVersion,
            ]
        }

        return parameters
    }
    // swiftlint:enable cyclomatic_complexity

    private enum EventKey: String {
        case screenPaymentOptions
        case screenPaymentContract
        case screenLinkedCardForm
        case screenBankCardForm
        case screenError
        case screen3ds
        case screenRecurringCardForm
        case actionTokenize
        case actionPaymentAuthorization
        case actionLogout
        case actionAuthWithoutWallet
        case actionBankCardForm

        // MARK: - Authorization

        case userStartAuthorization
        case userCancelAuthorization
        case userSuccessAuthorization
        case userFailedAuthorization
    }
}

private func logAnalyticsEventNamed(
    _ name: String,
    parameters: [String: String]?,
    isLoggingEnabled: Bool
) {
    guard isLoggingEnabled == true else { return }
    #if DEBUG
    guard let parameters = parameters else {
        print("YandexMetrica event name: \(name)")
        return
    }
    print("YandexMetrica event name: \(name), parameters: \(parameters)")
    #endif
}
