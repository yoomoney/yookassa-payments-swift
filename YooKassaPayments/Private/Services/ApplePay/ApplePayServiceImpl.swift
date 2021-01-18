import class PassKit.PKPaymentAuthorizationViewController
import enum YooKassaPaymentsApi.PaymentMethodType

struct ApplePayServiceImpl {}

// MARK: - ApplePayService

extension ApplePayServiceImpl: ApplePayService {
    func filteredByApplePayAvailability(
        _ supportedTypes: Set<PaymentMethodType>
    ) -> Set<PaymentMethodType> {
        var supportedTypes = supportedTypes
        let networks = ApplePayConstants.paymentNetworks

        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: networks) == false {
            supportedTypes.remove(.applePay)
        }
        return supportedTypes
    }
}
