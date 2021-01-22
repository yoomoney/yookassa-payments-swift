import YooKassaPaymentsApi

/// Bank card details
struct PaymentMethodBankCard {

    /// The first 6 digits of the card number (BIN).
    let first6: String

    /// The last 4 digits of the card number.
    let last4: String

    /// Validity, year, YYYY.
    let expiryYear: String

    /// The validity period of the month, MM.
    let expiryMonth: String

    /// Type of Bank card.
    let cardType: BankCardType

    /// Creates instance of `PaymentMethodBankCard`
    ///
    /// - Parameters:
    ///   - first6: The first 6 digits of the card number (BIN).
    ///   - last4: The last 4 digits of the card number.
    ///   - expiryYear: Validity, year, YYYY.
    ///   - expiryMonth: The validity period of the month, MM.
    ///   - cardType: Type of Bank card.
    ///
    /// - Returns: Instance of `PaymentMethodBankCard`
    init(
        first6: String,
        last4: String,
        expiryYear: String,
        expiryMonth: String,
        cardType: BankCardType
    ) {
        self.first6 = first6
        self.last4 = last4
        self.expiryYear = expiryYear
        self.expiryMonth = expiryMonth
        self.cardType = cardType
    }
}

// MARK: - PaymentMethodBankCard converter

extension PaymentMethodBankCard {
    init(_ paymentMethodBankCard: YooKassaPaymentsApi.PaymentMethodBankCard) {
        self.init(
            first6: paymentMethodBankCard.first6,
            last4: paymentMethodBankCard.last4,
            expiryYear: paymentMethodBankCard.expiryYear,
            expiryMonth: paymentMethodBankCard.expiryMonth,
            cardType: paymentMethodBankCard.cardType
        )
    }

    var paymentsModel: YooKassaPaymentsApi.PaymentMethodBankCard {
        return YooKassaPaymentsApi.PaymentMethodBankCard(self)
    }
}

extension YooKassaPaymentsApi.PaymentMethodBankCard {
    init(_ paymentMethodBankCard: PaymentMethodBankCard) {
        self.init(
            first6: paymentMethodBankCard.first6,
            last4: paymentMethodBankCard.last4,
            expiryYear: paymentMethodBankCard.expiryYear,
            expiryMonth: paymentMethodBankCard.expiryMonth,
            cardType: paymentMethodBankCard.cardType
        )
    }

    var plain: PaymentMethodBankCard {
        return PaymentMethodBankCard(self)
    }
}
