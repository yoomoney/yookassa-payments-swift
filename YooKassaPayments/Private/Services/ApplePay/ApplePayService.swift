import enum YooKassaPaymentsApi.PaymentMethodType

protocol ApplePayService {
    func filteredByApplePayAvailability(
        _ supportedTypes: Set<PaymentMethodType>
    ) -> Set<PaymentMethodType>
}
