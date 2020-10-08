import When
import YandexCheckoutPaymentsApi

enum PaymentProcessingError: PresentableError {
    case emptyList
    case internetConnection

    var title: String? {
        return nil
    }

    var message: String {
        switch self {
        case .emptyList:
            return §Localized.Error.emptyPaymentMethods
        case .internetConnection:
            return §Localized.Error.internetConnection
        }
    }

    var style: PresentableNotificationStyle {
        return .alert
    }
    var actions: [PresentableNotificationAction] {
        return []
    }
}

protocol PaymentProcessing {
    func fetchPaymentOptions(
        clientApplicationKey: String,
        moneyCenterAuthorization: String?,
        gatewayId: String?,
        amount: String?,
        currency: String?,
        getSavePaymentMethod: Bool?
    ) -> Promise<[PaymentOption]>

    func fetchPaymentMethod(
        clientApplicationKey: String,
        paymentMethodId: String
    ) -> Promise<YandexCheckoutPaymentsApi.PaymentMethod>

    func tokenizeBankCard(
        clientApplicationKey: String,
        bankCard: BankCard,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens>

    func tokenizeWallet(
        clientApplicationKey: String,
        walletAuthorization: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens>

    func tokenizeLinkedBankCard(
        clientApplicationKey: String,
        walletAuthorization: String,
        cardId: String,
        csc: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens>

    func tokenizeSberbank(
        clientApplicationKey: String,
        phoneNumber: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens>

    func tokenizeApplePay(
        clientApplicationKey: String,
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens>

    func tokenizeRepeatBankCard(
        clientApplicationKey: String,
        amount: MonetaryAmount,
        tmxSessionId: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodId: String,
        csc: String
    ) -> Promise<Tokens>
}

// MARK: - Localized

private extension PaymentProcessingError {
    enum Localized {
        enum Error: String {
            case emptyPaymentMethods = "Error.emptyPaymentOptions"
            case internetConnection = "Error.internet"
        }
    }
}
