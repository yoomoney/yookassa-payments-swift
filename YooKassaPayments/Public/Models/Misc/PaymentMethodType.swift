import YooKassaPaymentsApi

/// Type of the source of funds for the payment.
public enum PaymentMethodType: String {
    /// Bank Card.
    case bankCard = "bank_card"
    /// Cash.
    case cash
    /// Qiwi.
    case qiwi
    /// Alfabank.
    case alfabank
    /// Webmoney.
    case webmoney
    /// Sberbank.
    case sberbank
    /// ApplePay.
    case applePay = "apple_pay"
    /// YooMoney
    case yooMoney = "yoo_money"
}

// MARK: - PaymentMethodType converter

extension PaymentMethodType {
    init(_ paymentMethodType: YooKassaPaymentsApi.PaymentMethodType) {
        switch paymentMethodType {
        case .bankCard:
            self = .bankCard
        case .cash:
            self = .cash
        case .qiwi:
            self = .qiwi
        case .alfabank:
            self = .alfabank
        case .webmoney:
            self = .webmoney
        case .sberbank:
            self = .sberbank
        case .applePay:
            self = .applePay
        case .yooMoney:
            self = .yooMoney
        @unknown default:
            fatalError("unsuported")
        }
    }

    var paymentsModel: YooKassaPaymentsApi.PaymentMethodType {
        return YooKassaPaymentsApi.PaymentMethodType(self)
    }
}

extension YooKassaPaymentsApi.PaymentMethodType {
    init(_ paymentMethodType: PaymentMethodType) {
        switch paymentMethodType {
        case .bankCard:
            self = .bankCard
        case .cash:
            self = .cash
        case .qiwi:
            self = .qiwi
        case .alfabank:
            self = .alfabank
        case .webmoney:
            self = .webmoney
        case .sberbank:
            self = .sberbank
        case .applePay:
            self = .applePay
        case .yooMoney:
            self = .yooMoney
        }
    }

    var plain: PaymentMethodType {
        return PaymentMethodType(self)
    }
}
