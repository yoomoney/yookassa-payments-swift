import enum YooKassaPaymentsApi.PaymentMethodType
import class YooKassaPaymentsApi.PaymentOption

final class PaymentMethodHandlerServiceImpl {

    // MARK: - Init data

    private let supportedTypes: Set<PaymentMethodType>
    private let tokenizationSettings: TokenizationSettings
    private let applePayHandler: ApplePayHandlerProcessing

    // MARK: - Init

    init(
        tokenizationSettings: TokenizationSettings,
        supportedTypes: Set<PaymentMethodType>,
        applePayHandler: ApplePayHandlerProcessing
    ) {
        self.tokenizationSettings = tokenizationSettings
        self.supportedTypes = supportedTypes
        self.applePayHandler = applePayHandler
    }
}

// MARK: - PaymentMethodHandlerService

extension PaymentMethodHandlerServiceImpl: PaymentMethodHandlerService {
    func filterPaymentMethods(
        _ paymentMethods: [PaymentOption]
    ) -> [PaymentOption] {
        let handledSupportedTypes = applePayHandler
            .filteredByApplePayAvailability(supportedTypes)
        let supportedPaymentMethods = paymentMethods.filter {
            handledSupportedTypes.contains($0.paymentMethodType)
        }
        return supportedPaymentMethods
    }
}
