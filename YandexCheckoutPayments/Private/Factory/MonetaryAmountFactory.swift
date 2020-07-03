import YandexCheckoutPaymentsApi
import YandexCheckoutWalletApi

typealias PaymentsMonetaryAmount = YandexCheckoutPaymentsApi.MonetaryAmount
typealias WalletMonetaryAmount = YandexCheckoutWalletApi.MonetaryAmount

enum MonetaryAmountFactory {
    static func makeWalletMonetaryAmount(_ amount: Amount) -> WalletMonetaryAmount {
        return WalletMonetaryAmount(value: amount.value, currency: amount.currency.rawValue)
    }

    static func makeWalletMonetaryAmount(_ amount: PaymentsMonetaryAmount) -> WalletMonetaryAmount {
        return WalletMonetaryAmount(value: amount.value, currency: amount.currency)
    }

    static func makePaymentsMonetaryAmount(_ amount: Amount) -> PaymentsMonetaryAmount {
        return PaymentsMonetaryAmount(value: amount.value, currency: amount.currency.rawValue)
    }

    static func makeAmount(_ amount: PaymentsMonetaryAmount) -> Amount {
        let currency = Currency(rawValue: amount.currency) ?? Currency.custom(amount.currency)
        return Amount(value: amount.value, currency: currency)
    }
}
