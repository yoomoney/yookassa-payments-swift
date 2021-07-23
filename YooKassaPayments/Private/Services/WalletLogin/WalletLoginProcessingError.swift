enum WalletLoginProcessingError: Error {
    case unsupportedAuthType
    case invalidAnswer(AuthTypeState?)
    case invalidContext
    case authCheckInvalidContext
    case sessionsExceeded
    case sessionDoesNotExist
    case verifyAttemptsExceeded(AuthTypeState?)
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
            message = Localized.Error.resendAuthCodeAndStartOver
        case .verifyAttemptsExceeded:
            message = Localized.Error.endedAttemptsToEnterStartOver
        case .unsupportedAuthType:
            message = Localized.Error.unsupportedAuthType
        default:
            message = CommonLocalized.Error.unknown
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
        enum Error {
            static let resendAuthCodeAndStartOver = NSLocalizedString(
                "Error.resendAuthCodeAndStartOver",
                bundle: Bundle.framework,
                value: "Не получилось, попробуйте заново",
                comment: "Пользователь ввел верный код, но возникла ошибка. Создаем новую сессию на авторизацию"
            )
            static let endedAttemptsToEnterStartOver = NSLocalizedString(
                "Error.endedAttemptsToEnterStartOver",
                bundle: Bundle.framework,
                value: "Слишком много попыток. Попробуйте позже",
                comment: "Пользователь потратил все попытки ввода. Создаем новую сессию на авторизацию"
            )
            static let unsupportedAuthType = NSLocalizedString(
                "Error.endedAttemptsToEnterStartOver",
                bundle: Bundle.framework,
                value: "Слишком много попыток. Попробуйте позже",
                comment: "Пользователь потратил все попытки ввода. Создаем новую сессию на авторизацию"
            )
        }
    }
}
