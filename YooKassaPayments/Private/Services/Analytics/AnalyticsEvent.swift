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

    case screenDetailsUnbindWalletCard(sdkVersion: String)
    case screenUnbindCard(cardType: LinkedCardType)

    // MARK: - Actions

    /// Create a payment token with the payment method selected.
    case actionTokenize(scheme: TokenizeScheme, authType: AuthType, tokenType: AuthTokenType?, sdkVersion: String)

    /// Payment authorization.
    case actionPaymentAuthorization(authPaymentStatus: AuthPaymentStatus, sdkVersion: String)

    /// The user is logged out.
    case actionLogout(sdkVersion: String)

    /// Authorization without wallet.
    case actionAuthWithoutWallet(sdkVersion: String)

    /// BankCard form interactions.
    case actionBankCardForm(action: BankCardFormAction, sdkVersion: String)

    case userStartAuthorization(sdkVersion: String)
    case userCancelAuthorization(sdkVersion: String)

    case actionMoneyAuthLogin(
        scheme: MoneyAuthLoginScheme,
        status: MoneyAuthLoginStatus,
        sdkVersion: String
    )

    /// SberPay confirmation
    case actionSberPayConfirmation(sberPayConfirmationStatus: SberPayConfirmationStatus, sdkVersion: String)

    case actionUnbindBankCard(actionUnbindCardStatus: ActionUnbindCardStatus)

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
        case sberpay = "sber-pay"
        case customerIdLinkedCard = "customer-id-linked-card"
        case customerIdLinkedCardCvc = "customer-id-linked-card-cvc"

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
        case action
        case moneyAuthLoginScheme
        case moneyAuthLoginStatus
        case sberPayConfirmationStatus
        case linkedCardType
        case actionUnbindCardStatus
    }

    // MARK: - BankCardForm actions

    enum BankCardFormAction: String {
        /// The user clicked on the scan button;
        case scanBankCardAction
        /// The user entered the wrong card number;
        case cardNumberInputError
        /// The user entered the wrong card expiration date;
        case cardExpiryInputError
        /// The user entered an incorrect CVC;
        case cardCvcInputError
        /// The user erased the card number (tap on the cross);
        case cardNumberClearAction
        /// Successful entry of bank card information;
        case cardNumberInputSuccess
        /// The user clicked on the arrow and moved to the next field;
        case cardNumberContinueAction
        /// Returns to the card number input field.
        case cardNumberReturnToEdit

        var key: String {
            Key.action.rawValue
        }
    }

    enum MoneyAuthLoginScheme: String {
        case moneyAuthSdk
        case yoomoneyApp

        var key: String {
            Key.moneyAuthLoginScheme.rawValue
        }
    }

    enum MoneyAuthLoginStatus {
        case success
        case fail(String)
        case canceled

        var rawValue: String {
            switch self {
            case .success:
                return "Success"
            case .fail:
                return "Fail"
            case .canceled:
                return "Canceled"
            }
        }

        var key: String {
            Key.moneyAuthLoginStatus.rawValue
        }
    }

    // MARK: - SberPayConfirmationStatus

    enum SberPayConfirmationStatus: String {
        case success = "Success"

        var key: String {
            return Key.sberPayConfirmationStatus.rawValue
        }
    }

    enum LinkedCardType: String {
        case wallet = "Wallet"
        case bankCard = "BankCard"
        var key: String { Key.linkedCardType.rawValue }
    }

    enum ActionUnbindCardStatus: String {
        case fail = "Fail"
        case success = "Success"
        var key: String { Key.actionUnbindCardStatus.rawValue }
    }
}

// MARK: - Primitive type keys

extension AnalyticsEvent {
    enum Keys: String {
        case error
        case msdkVersion
    }
}
