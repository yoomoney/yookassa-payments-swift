import YooKassaPaymentsApi

/// Tokenization payments data.
public struct Tokens {

    /// One-time token for payment.
    public let paymentToken: String

    /// Creates instance of `Tokens`.
    ///
    /// - Parameters:
    ///   - paymentToken: One-time token for payment.
    ///
    /// - Returns: Instance of `Tokens`.
    public init(paymentToken: String) {
        self.paymentToken = paymentToken
    }
}

// MARK: - Tokens converter

extension Tokens {
    init(_ tokens: YooKassaPaymentsApi.Tokens) {
        self.init(
            paymentToken: tokens.paymentToken
        )
    }

    var paymentsModel: YooKassaPaymentsApi.Tokens {
        return YooKassaPaymentsApi.Tokens(self)
    }
}

extension YooKassaPaymentsApi.Tokens {
    init(_ tokens: Tokens) {
        self.init(
            paymentToken: tokens.paymentToken
        )
    }

    var plain: Tokens {
        return Tokens(self)
    }
}
