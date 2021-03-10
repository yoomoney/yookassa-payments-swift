import YooKassaWalletApi

/// How many times are allowed to pay a generated token: one-time or unlimited.
enum PaymentUsageLimit: String {

    /// One-time.
    case single = "Single"

    /// Unlimited.
    case multiple = "Multiple"
}

// MARK: - PaymentUsageLimit converter

extension PaymentUsageLimit {
    init(_ paymentUsageLimit: YooKassaWalletApi.PaymentUsageLimit) {
        switch paymentUsageLimit {
        case .single:
            self = .single
        case .multiple:
            self = .multiple
        }
    }

    var walletModel: YooKassaWalletApi.PaymentUsageLimit {
        return YooKassaWalletApi.PaymentUsageLimit(self)
    }
}

extension YooKassaWalletApi.PaymentUsageLimit {
    init(_ paymentUsageLimit: PaymentUsageLimit) {
        switch paymentUsageLimit {
        case .single:
            self = .single
        case .multiple:
            self = .multiple
        }
    }

    var plain: PaymentUsageLimit {
        return PaymentUsageLimit(self)
    }
}
