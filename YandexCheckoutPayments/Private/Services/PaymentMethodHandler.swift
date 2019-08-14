import FunctionalSwift
import enum YandexCheckoutPaymentsApi.PaymentMethodType
import class YandexCheckoutPaymentsApi.PaymentOption

struct PaymentMethodHandler {

    static func makePaymentMethodHandler(_ tokenizationSettings: TokenizationSettings) -> PaymentMethodHandler {
        let supportedTypes = tokenizationSettings.paymentMethodTypes.rawValue
        return PaymentMethodHandler(tokenizationSettings: tokenizationSettings,
                                    supportedTypes: supportedTypes,
                                    applePayHandler: ApplePayHandler())
    }

    // MARK: - Initial parameters
    private let supportedTypes: Set<PaymentMethodType>
    private let tokenizationSettings: TokenizationSettings
    private let applePayHandler: ApplePayHandlerProcessing

    // MARK: - Creating object
    init(tokenizationSettings: TokenizationSettings,
         supportedTypes: Set<PaymentMethodType>,
         applePayHandler: ApplePayHandlerProcessing) {
        self.tokenizationSettings = tokenizationSettings
        self.supportedTypes = supportedTypes
        self.applePayHandler = applePayHandler
    }

    // MARK: - Handling logic
    func filterPaymentMethods(_ paymentMethods: [PaymentOption]) -> [PaymentOption] {
        let handledSupportedTypes = applePayHandler.filteredByApplePayAvailability(supportedTypes)
        let supportedPaymentMethods = paymentMethods.filter { handledSupportedTypes.contains($0.paymentMethodType) }
        return supportedPaymentMethods
    }
}
