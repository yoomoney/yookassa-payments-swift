enum AnalyticsEvent {

    // MARK: - Screen viewing events.

    /// Open the payment method selection screen.
    case screenPaymentOptions(authType: AuthType, sdkVersion: String)

    /// The opening screen of the contract.
    case screenPaymentContract(authType: AuthType, scheme: TokenizeScheme, sdkVersion: String)

    /// Open the Linked Bank card for data entry screen.
    case screenLinkedCardForm(sdkVersion: String)

    /// Open the Bank card screen for entering Data.
    case screenBankCardForm(authType: AuthType, sdkVersion: String)

    /// The opening screen of the error.
    case screenError(authType: AuthType, scheme: TokenizeScheme?, sdkVersion: String)

    /// The opening pages 3DS.
    case screen3ds(sdkVersion: String)

    /// Open Bank Card screen with screen recurring
    case screenRecurringCardForm(sdkVersion: String)

    // MARK: - Actions

    /// Create a payment token with the payment method selected.
    case actionTokenize(scheme: TokenizeScheme, authType: AuthType, tokenType: AuthTokenType?, sdkVersion: String)

    /// Payment authorization.
    case actionPaymentAuthorization(authPaymentStatus: AuthPaymentStatus, sdkVersion: String)

    /// The user is logged out.
    case actionLogout(sdkVersion: String)

    /// Authorization without wallet.
    case actionAuthWithoutWallet(sdkVersion: String)

    case userStartAuthorization(sdkVersion: String)
    case userCancelAuthorization(sdkVersion: String)
    case userSuccessAuthorization(moneyAuthProcessType: MoneyAuthProcessType, sdkVersion: String)
    case userFailedAuthorization(error: String, sdkVersion: String)

    // MARK: - Analytic parameters.

    /// Current status of user authorization.
    enum AuthType: String {

        /// The user is not authorized.
        case withoutAuth

        /// Successfully completed authorization in Money center authorization
        case moneyAuth

        /// Successful payment authorization in the wallet.
        case paymentAuth

        var key: String {
            return Key.authType.rawValue
        }
    }

    /// Creating a payment token.
    enum TokenizeScheme: String {
        case wallet
        case linkedCard = "linked-card"
        case bankCard = "bank-card"
        case smsSbol = "sms-sbol"
        case applePay = "apple-pay"
        case recurringCard = "recurring-card"

        var key: String {
            return Key.tokenizeScheme.rawValue
        }
    }

    /// Token type.
    enum AuthTokenType: String {

        /// one-time authorization token.
        case single

        /// reusable authorization token.
        case multiple

        var key: String {
            return Key.authTokenType.rawValue
        }
    }

    /// Payment authorization status.
    enum AuthPaymentStatus: String {
        case success = "Success"
        case fail = "Fail"

        var key: String {
            return Key.authPaymentStatus.rawValue
        }
    }

    private enum Key: String {
        case tokenizeScheme
        case authType
        case authTokenType
        case authPaymentStatus
        case moneyAuthProcessType
    }

    // MARK: - Authorization

    enum MoneyAuthProcessType: String {
        case enrollment
        case login
        case migration
        case unknown

        var key: String {
            return Key.moneyAuthProcessType.rawValue
        }
    }
}

extension AnalyticsEvent {
    enum Keys: String {
        case error
        case msdkVersion
    }
}