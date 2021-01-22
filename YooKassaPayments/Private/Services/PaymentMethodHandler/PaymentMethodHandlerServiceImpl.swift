import YooKassaPaymentsApi

final class PaymentMethodHandlerServiceImpl {

    // MARK: - Init data

    private let supportedTypes: Set<PaymentMethodType>
    private let tokenizationSettings: TokenizationSettings
    private let applePayService: ApplePayService

    // MARK: - Init

    init(
        tokenizationSettings: TokenizationSettings,
        supportedTypes: Set<PaymentMethodType>,
        applePayService: ApplePayService
    ) {
        self.tokenizationSettings = tokenizationSettings
        self.supportedTypes = supportedTypes
        self.applePayService = applePayService
    }
}

// MARK: - PaymentMethodHandlerService

extension PaymentMethodHandlerServiceImpl: PaymentMethodHandlerService {
    func filterPaymentMethods(
        _ paymentMethods: [PaymentOption]
    ) -> [PaymentOption] {
        let handledSupportedTypes = applePayService
            .filteredByApplePayAvailability(supportedTypes)
        let supportedPaymentMethods = paymentMethods.filter {
            handledSupportedTypes.contains($0.paymentMethodType.plain)
        }
        return supportedPaymentMethods
    }
}
