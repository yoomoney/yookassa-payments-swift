import YooKassaWalletApi

/// Specific description by type of authorization
enum Specific {

    /// By sms
    case sms(SmsDescription?)

    /// By time one token password
    case totp(TotpDescription?)

    /// By secure password
    case securePassword

    /// By emergency code
    case emergency(EmergencyDescription?)

    // TODO: - Add public init for PushDescription in YooKassaWalletApi
    /// By push notification
    case push(YooKassaWalletApi.AuthTypeState.Specific.PushDescription?)

    /// By OAuth token
    case oauthToken

    /// The authorization type
    var type: AuthType {
        switch self {
        case .sms:
            return .sms
        case .totp:
            return .totp
        case .securePassword:
            return .securePassword
        case .emergency:
            return .emergency
        case .push:
            return .push
        case .oauthToken:
            return .oauthToken
        }
    }
}

// MARK: - Authorization description structures

extension Specific {

    /// Description of authorization by sms
    struct SmsDescription {

        /// The number of code symbols that must be entered by the user
        let codeLength: Int

        /// The remaining number of sessions
        let sessionsLeft: Int

        /// The remaining number of seconds before the expiration of the lifetime of the session.
        let sessionTimeLeft: Int?

        /// The remaining number of seconds before the opportunity to create a new session.
        let nextSessionTimeLeft: Int?

        init(
            codeLength: Int,
            sessionsLeft: Int,
            sessionTimeLeft: Int?,
            nextSessionTimeLeft: Int?
        ) {
            self.codeLength = codeLength
            self.sessionsLeft = sessionsLeft
            self.sessionTimeLeft = sessionTimeLeft
            self.nextSessionTimeLeft = nextSessionTimeLeft
        }
    }

    /// Description of authorization by push notification
    struct PushDescription {

        /// The remaining number of seconds before the expiration of the lifetime of the session.
        let sessionTimeLeft: Int?

        init(
            sessionTimeLeft: Int?
        ) {
            self.sessionTimeLeft = sessionTimeLeft
        }
    }

    /// Description of authorization by emergency code
    struct EmergencyDescription {

        /// The remaining number of emergency codes
        let codesLeft: Int

        let codeLength: Int

        init(
            codesLeft: Int,
            codeLength: Int
        ) {
            self.codesLeft = codesLeft
            self.codeLength = codeLength
        }
    }

    /// Description of authorization by totp code
    struct TotpDescription {

        /// The number of code symbols that must be entered by the user
        let codeLength: Int

        init(
            codeLength: Int
        ) {
            self.codeLength = codeLength
        }
    }
}

extension Specific {
    init(_ specific: YooKassaWalletApi.AuthTypeState.Specific) {
        switch specific {
        case let .sms(description):
            self = .sms(description?.plain)
        case let .totp(description):
            self = .totp(description?.plain)
        case .securePassword:
            self = .securePassword
        case let .emergency(description):
            self = .emergency(description?.plain)
        case let .push(description):
            self = .push(description)
        case .oauthToken:
            self = .oauthToken
        }
    }

    var walletModel: YooKassaWalletApi.AuthTypeState.Specific {
        return YooKassaWalletApi.AuthTypeState.Specific(self)
    }
}

extension YooKassaWalletApi.AuthTypeState.Specific {
    init(_ specific: Specific) {
        switch specific {
        case let .sms(description):
            self = .sms(description?.walletModel)
        case let .totp(description):
            self = .totp(description?.walletModel)
        case .securePassword:
            self = .securePassword
        case let .emergency(description):
            self = .emergency(description?.walletModel)
        case let .push(description):
            self = .push(description)
        case .oauthToken:
            self = .oauthToken
        }
    }

    var plain: Specific {
        return Specific(self)
    }
}

// MARK: - SmsDescription converter

extension Specific.SmsDescription {
    init(_ description: YooKassaWalletApi.AuthTypeState.Specific.SmsDescription) {
        self.init(
            codeLength: description.codeLength,
            sessionsLeft: description.sessionsLeft,
            sessionTimeLeft: description.sessionTimeLeft,
            nextSessionTimeLeft: description.nextSessionTimeLeft
        )
    }

    var walletModel: YooKassaWalletApi.AuthTypeState.Specific.SmsDescription {
        return YooKassaWalletApi.AuthTypeState.Specific.SmsDescription(self)
    }
}

extension YooKassaWalletApi.AuthTypeState.Specific.SmsDescription {
    init(_ description: Specific.SmsDescription) {
        self.init(
            codeLength: description.codeLength,
            sessionsLeft: description.sessionsLeft,
            sessionTimeLeft: description.sessionTimeLeft,
            nextSessionTimeLeft: description.nextSessionTimeLeft
        )
    }

    var plain: Specific.SmsDescription {
        return Specific.SmsDescription(self)
    }
}

// MARK: - EmergencyDescription converter

extension Specific.EmergencyDescription {
    init(_ description: YooKassaWalletApi.AuthTypeState.Specific.EmergencyDescription) {
        self.init(
            codesLeft: description.codesLeft,
            codeLength: description.codeLength
        )
    }

    var walletModel: YooKassaWalletApi.AuthTypeState.Specific.EmergencyDescription {
        return YooKassaWalletApi.AuthTypeState.Specific.EmergencyDescription(self)
    }
}

extension YooKassaWalletApi.AuthTypeState.Specific.EmergencyDescription {
    init(_ description: Specific.EmergencyDescription) {
        self.init(
            codesLeft: description.codesLeft,
            codeLength: description.codeLength
        )
    }

    var plain: Specific.EmergencyDescription {
        return Specific.EmergencyDescription(self)
    }
}

// MARK: - TotpDescription converter

extension Specific.TotpDescription {
    init(_ description: YooKassaWalletApi.AuthTypeState.Specific.TotpDescription) {
        self.init(
            codeLength: description.codeLength
        )
    }

    var walletModel: YooKassaWalletApi.AuthTypeState.Specific.TotpDescription {
        return YooKassaWalletApi.AuthTypeState.Specific.TotpDescription(self)
    }
}

extension YooKassaWalletApi.AuthTypeState.Specific.TotpDescription {
    init(_ description: Specific.TotpDescription) {
        self.init(
            codeLength: description.codeLength
        )
    }

    var plain: Specific.TotpDescription {
        return Specific.TotpDescription(self)
    }
}
