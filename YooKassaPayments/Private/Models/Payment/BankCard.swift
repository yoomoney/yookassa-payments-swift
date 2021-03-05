import YooKassaPaymentsApi

/// Bank card data.
struct BankCard: Codable {

    /// Bank card number.
    let number: String

    /// Validity, year, YYYY.
    let expiryYear: String

    /// The validity period of the month, MM.
    let expiryMonth: String

    /// The CVC2 or CVV2 code, 3 or 4 characters, is printed on the back of the card.
    let csc: String

    /// The name of the card owner.
    let cardholder: String?

    /// Creates instance of `BankCard`.
    ///
    /// - Parameters:
    ///   - number: Bank card number.
    ///   - expiryYear: Validity, year, YYYY.
    ///   - expiryMonth: The validity period of the month, MM.
    ///   - csc: The CVC2 or CVV2 code, 3 or 4 characters, is printed on the back of the card.
    ///   - cardholder: The name of the card owner.
    ///
    /// - Returns: Instance of `BankCard`
    init(
        number: String,
        expiryYear: String,
        expiryMonth: String,
        csc: String,
        cardholder: String?
    ) {
        self.number = number
        self.expiryYear = expiryYear
        self.expiryMonth = expiryMonth
        self.csc = csc
        self.cardholder = cardholder
    }
}

// MARK: - BankCard converter

extension BankCard {
    init(_ bankCard: YooKassaPaymentsApi.BankCard) {
        self.init(
            number: bankCard.number,
            expiryYear: bankCard.expiryYear,
            expiryMonth: bankCard.expiryMonth,
            csc: bankCard.csc,
            cardholder: bankCard.cardholder
        )
    }

    var paymentsModel: YooKassaPaymentsApi.BankCard {
        return YooKassaPaymentsApi.BankCard(self)
    }
}

extension YooKassaPaymentsApi.BankCard {
    init(_ bankCard: BankCard) {
        self.init(
            number: bankCard.number,
            expiryYear: bankCard.expiryYear,
            expiryMonth: bankCard.expiryMonth,
            csc: bankCard.csc,
            cardholder: bankCard.cardholder
        )
    }

    var plain: BankCard {
        return BankCard(self)
    }
}
