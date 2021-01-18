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
