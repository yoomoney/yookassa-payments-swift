import enum YooKassaPaymentsApi.PaymentMethodType

struct PaymentMethodHandlerServiceAssembly {
    static func makeService(
        _ tokenizationSettings: TokenizationSettings
    ) -> PaymentMethodHandlerService {
        let supportedTypes = tokenizationSettings.paymentMethodTypes.rawValue
        let applePayService = ApplePayServiceImpl()
        return PaymentMethodHandlerServiceImpl(
            tokenizationSettings: tokenizationSettings,
            supportedTypes: supportedTypes,
            applePayService: applePayService
        )
    }
}
