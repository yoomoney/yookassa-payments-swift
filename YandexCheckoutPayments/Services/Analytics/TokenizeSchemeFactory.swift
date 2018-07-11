import YandexCheckoutPaymentsApi

enum TokenizeSchemeFactory {

    static func makeTokenizeScheme(_ paymentOption: PaymentOption) -> AnalyticsEvent.TokenizeScheme {

        let scheme: AnalyticsEvent.TokenizeScheme

        switch paymentOption {
        case is PaymentInstrumentYandexMoneyWallet:
            scheme = .wallet
        case is PaymentInstrumentYandexMoneyLinkedBankCard:
            scheme = .linkedCard
        default:
            scheme = makeTokenizeScheme(paymentOption.paymentMethodType)
        }

        return scheme
    }

    private static func makeTokenizeScheme(_ paymentMethodType: PaymentMethodType)
            -> AnalyticsEvent.TokenizeScheme {

        let scheme: AnalyticsEvent.TokenizeScheme

        switch paymentMethodType {

        case .sberbank:
            scheme = .smsSbol
        default:
            scheme = .bankCard
        }

        return scheme
    }
}
