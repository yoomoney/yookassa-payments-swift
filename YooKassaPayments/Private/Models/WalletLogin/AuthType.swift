import YooKassaWalletApi

/// The authorization type of the user
enum AuthType: String {

    /// By sms
    case sms = "Sms"

    /// By time one token password
    case totp = "Totp"

    /// By secure password
    case securePassword = "SecurePassword"

    /// By emergency code
    case emergency = "Emergency"

    /// By push notification
    case push = "Push"

    /// By OAuth token
    case oauthToken = "OauthToken"
}

// MARK: - AuthType converter

extension AuthType {
    init(_ authType: YooKassaWalletApi.AuthType) {
        switch authType {
        case .sms:
            self = .sms
        case .totp:
            self = .totp
        case .securePassword:
            self = .securePassword
        case .emergency:
            self = .emergency
        case .push:
            self = .push
        case .oauthToken:
            self = .oauthToken
        }
    }

    var walletModel: YooKassaWalletApi.AuthType {
        return YooKassaWalletApi.AuthType(self)
    }
}

extension YooKassaWalletApi.AuthType {
    init(_ authType: AuthType) {
        switch authType {
        case .sms:
            self = .sms
        case .totp:
            self = .totp
        case .securePassword:
            self = .securePassword
        case .emergency:
            self = .emergency
        case .push:
            self = .push
        case .oauthToken:
            self = .oauthToken
        }
    }

    var plain: AuthType {
        return AuthType(self)
    }
}
