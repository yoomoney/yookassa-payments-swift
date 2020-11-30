import class PassKit.PKPaymentAuthorizationViewController
import struct PassKit.PKPaymentNetwork
import enum YooKassaPaymentsApi.PaymentMethodType

enum ApplePayConstants {
    static let paymentNetworks: [PKPaymentNetwork] = [.amex, .masterCard, .visa]
}

protocol ApplePayHandlerProcessing {
    func filteredByApplePayAvailability(_ supportedTypes: Set<PaymentMethodType>) -> Set<PaymentMethodType>
}

struct ApplePayHandler {}

// MARK: - ApplePayHandlerProcessing

extension ApplePayHandler: ApplePayHandlerProcessing {
    func filteredByApplePayAvailability(_ supportedTypes: Set<PaymentMethodType>) -> Set<PaymentMethodType> {
        var supportedTypes = supportedTypes
        let networks = ApplePayConstants.paymentNetworks

        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: networks) == false {
            supportedTypes.remove(.applePay)
        }
        return supportedTypes
    }
}
