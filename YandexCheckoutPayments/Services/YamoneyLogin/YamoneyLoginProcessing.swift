import YandexCheckoutWalletApi
import class When.Promise

enum YamoneyLoginResponse {
    case authorized(CheckoutTokenIssueExecute)
    case notAuthorized(authTypeState: AuthTypeState, processId: String, authContextId: String)
}

enum YamoneyLoginProcessingError: Error {
    case unsupportedAuthType
    case invalidAnswer
    case invalidContext
    case authCheckInvalidContext
    case sessionsExceeded
    case sessionDoesNotExist
    case verifyAttemptsExceeded
    case executeError
}

// MARK: - PresentableError

extension YamoneyLoginProcessingError: PresentableError {

    var title: String? {
        return nil
    }

    var message: String {
        let message: String

        switch self {
        case .authCheckInvalidContext,
             .sessionDoesNotExist,
             .executeError:
            message = §Localized.Error.resendAuthCodeAndStartOver
        case .verifyAttemptsExceeded:
            message = §Localized.Error.endedAttemptsToEnterStartOver
        case .unsupportedAuthType:
            message = §Localized.Error.unsupportedAuthType
        default:
            message = §CommonLocalized.Error.unknown
        }
        return message
    }

    var style: PresentableNotificationStyle {
        return .alert
    }

    var actions: [PresentableNotificationAction] {
        return []
    }
}

protocol YamoneyLoginProcessing {

    func requestAuthorization(passportAuthorization: String,
                              merchantClientAuthorization: String,
                              instanceName: String,
                              singleAmountMax: MonetaryAmount?,
                              paymentUsageLimit: PaymentUsageLimit,
                              tmxSessionId: String) -> Promise<YamoneyLoginResponse>

    func startNewSession(passportAuthorization: String,
                         merchantClientAuthorization: String,
                         authContextId: String,
                         authType: AuthType) -> Promise<AuthTypeState>

    func checkUserAnswer(passportAuthorization: String,
                         merchantClientAuthorization: String,
                         authContextId: String,
                         authType: AuthType,
                         answer: String,
                         processId: String) -> Promise<String>
}

// MARK: - Localized

private extension YamoneyLoginProcessingError {
    enum Localized {
        enum Error: String {
            case resendAuthCodeAndStartOver = "Error.resendAuthCodeAndStartOver"
            case endedAttemptsToEnterStartOver = "Error.endedAttemptsToEnterStartOver"
            case unsupportedAuthType = "Error.unsupportedAuthType"
        }
    }
}
