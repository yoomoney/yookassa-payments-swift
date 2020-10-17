enum AnalyticsEvent {

    // MARK: - Screen viewing events.

    /// Open the payment method selection screen.
    case screenPaymentOptions(AuthType)

    /// The opening screen of the contract.
    case screenPaymentContract(authType: AuthType, scheme: TokenizeScheme)

    /// Open the Linked Bank card for data entry screen.
    case screenLinkedCardForm

    /// Open the Bank card screen for entering Data.
    case screenBankCardForm(AuthType)

    /// The opening screen of the error.
    case screenError(authType: AuthType, scheme: TokenizeScheme?)

    /// The opening pages 3DS.
    case screen3ds

    /// Open Bank Card screen with screen recurring
    case screenRecurringCardForm

    // MARK: - Actions

    /// Create a payment token with the payment method selected.
    case actionTokenize(scheme: TokenizeScheme, authType: AuthType, tokenType: AuthTokenType?)

    /// Authorization in Yandex Login.
    case actionYaLoginAuthorization(AuthYaLoginStatus)

    /// Payment authorization.
    case actionPaymentAuthorization(AuthPaymentStatus)

    /// The user is logged out.
    case actionLogout

    /// The user changed the payment method.
    case actionChangePaymentMethod

    /// Authorization without wallet.
    case actionAuthWithoutWallet

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

    /// Yandex Login authorization status.
    enum AuthYaLoginStatus: String {
        case success = "Success"
        case fail = "Fail"
        case canceled = "Canceled"
        case withoutWallet = "WithoutWallet"

        var key: String {
            return Key.authYaLoginStatus.rawValue
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
        case authYaLoginStatus
        case authPaymentStatus
    }
}
