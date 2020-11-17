import YooKassaWalletApi
import class When.Promise

enum WalletLoginResponse {
    case authorized(CheckoutTokenIssueExecute)
    case notAuthorized(authTypeState: AuthTypeState, processId: String, authContextId: String)
}

enum WalletLoginProcessingError: Error {
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

extension WalletLoginProcessingError: PresentableError {

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

protocol WalletLoginProcessing {

    func requestAuthorization(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        instanceName: String,
        singleAmountMax: MonetaryAmount?,
        paymentUsageLimit: PaymentUsageLimit,
        tmxSessionId: String
    ) -> Promise<WalletLoginResponse>

    func startNewSession(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType
    ) -> Promise<AuthTypeState>

    func checkUserAnswer(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType,
        answer: String,
        processId: String
    ) -> Promise<String>
}

// MARK: - Localized

private extension WalletLoginProcessingError {
    enum Localized {
        enum Error: String {
            case resendAuthCodeAndStartOver = "Error.resendAuthCodeAndStartOver"
            case endedAttemptsToEnterStartOver = "Error.endedAttemptsToEnterStartOver"
            case unsupportedAuthType = "Error.unsupportedAuthType"
        }
    }
}
