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
    func fetchPaymentOptions(clientApplicationKey: String,
                             passportToken: String?,
                             gatewayId: String?,
                             amount: String?,
                             currency: String?) -> Promise<[PaymentOption]>

    func tokenizeBankCard(clientApplicationKey: String,
                          bankCard: BankCard,
                          amount: MonetaryAmount?,
                          tmxSessionId: String) -> Promise<Tokens>

    func tokenizeWallet(clientApplicationKey: String,
                        yamoneyToken: String,
                        amount: MonetaryAmount?,
                        tmxSessionId: String) -> Promise<Tokens>

    func tokenizeLinkedBankCard(clientApplicationKey: String,
                                yamoneyToken: String,
                                cardId: String,
                                csc: String,
                                amount: MonetaryAmount?,
                                tmxSessionId: String) -> Promise<Tokens>

    func tokenizeSberbank(clientApplicationKey: String,
                          phoneNumber: String,
                          amount: MonetaryAmount?,
                          tmxSessionId: String) -> Promise<Tokens>

    func tokenizeApplePay(clientApplicationKey: String,
                          paymentData: String,
                          amount: MonetaryAmount?,
                          tmxSessionId: String) -> Promise<Tokens>
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
