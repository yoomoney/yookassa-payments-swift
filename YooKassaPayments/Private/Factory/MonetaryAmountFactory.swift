import YooKassaPaymentsApi

enum MonetaryAmountFactory {
    static func makeMonetaryAmount(
        _ amount: Amount
    ) -> MonetaryAmount {
        return MonetaryAmount(
            value: amount.value,
            currency: amount.currency.rawValue
        )
    }

    static func makePaymentsMonetaryAmount(
        _ amount: Amount
    ) -> YooKassaPaymentsApi.MonetaryAmount {
        return YooKassaPaymentsApi.MonetaryAmount(
            value: amount.value,
            currency: amount.currency.rawValue
        )
    }

    static func makeAmount(
        _ amount: MonetaryAmount
    ) -> Amount {
        let currency = Currency(rawValue: amount.currency) ?? Currency.custom(amount.currency)
        return Amount(
            value: amount.value,
            currency: currency
        )
    }

    static func makeAmount(
        _ amount: YooKassaPaymentsApi.MonetaryAmount
    ) -> Amount {
        let currency = Currency(rawValue: amount.currency) ?? Currency.custom(amount.currency)
        return Amount(
            value: amount.value,
            currency: currency
        )
    }
}
