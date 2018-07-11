import YandexCheckoutPaymentsApi
import YandexCheckoutWalletApi

typealias PaymentsMonetaryAmount = YandexCheckoutPaymentsApi.MonetaryAmount
typealias WalletMonetaryAmount = YandexCheckoutWalletApi.MonetaryAmount

typealias PaymentsCurrency = YandexCheckoutPaymentsApi.CurrencyCode
typealias WalletCurrency = YandexCheckoutWalletApi.CurrencyCode

enum MonetaryAmountFactory {
    static func makeWalletMonetaryAmount(_ amount: Amount) -> WalletMonetaryAmount {
        return WalletMonetaryAmount(value: amount.value, currency: makeCurrency(amount.currency))
    }

    static func makePaymentsMonetaryAmount(_ amount: Amount) -> PaymentsMonetaryAmount {
        return PaymentsMonetaryAmount(value: amount.value, currency: makeCurrency(amount.currency))
    }

    private static func makeCurrency(_ currency: Currency) -> WalletCurrency {
        let walletCurrency: WalletCurrency
        switch currency {
        case .rub:
            walletCurrency = .rub
        case .eur:
            walletCurrency = .eur
        case .usd:
            walletCurrency = .usd
        }
        return walletCurrency
    }

    private static func makeCurrency(_ currency: Currency) -> PaymentsCurrency {
        let paymentsCurrency: PaymentsCurrency
        switch currency {
        case .rub:
            paymentsCurrency = .rub
        case .eur:
            paymentsCurrency = .eur
        case .usd:
            paymentsCurrency = .usd
        }
        return paymentsCurrency
    }
}
