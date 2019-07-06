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

    static func makeWalletMonetaryAmount(_ amount: PaymentsMonetaryAmount) -> WalletMonetaryAmount {
        return WalletMonetaryAmount(value: amount.value, currency: makeCurrency(amount.currency))
    }

    static func makePaymentsMonetaryAmount(_ amount: Amount) -> PaymentsMonetaryAmount {
        return PaymentsMonetaryAmount(value: amount.value, currency: makeCurrency(amount.currency))
    }

    static func makeAmount(_ amount: PaymentsMonetaryAmount) -> Amount {
        return Amount(value: amount.value, currency: makeCurrency(amount.currency))
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

    private static func makeCurrency(_ paymentsCurrency: PaymentsCurrency) -> Currency {
        let currency: Currency
        switch paymentsCurrency {
        case .rub:
            currency = .rub
        case .eur:
            currency = .eur
        case .usd:
            currency = .usd
        }
        return currency
    }

    private static func makeCurrency(_ paymentsCurrency: PaymentsCurrency) -> WalletCurrency {
        let currency: WalletCurrency
        switch paymentsCurrency {
        case .rub:
            currency = .rub
        case .eur:
            currency = .eur
        case .usd:
            currency = .usd
        }
        return currency
    }
}
