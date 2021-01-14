import class YooKassaPaymentsApi.PaymentOption

protocol PaymentMethodHandlerService {
    func filterPaymentMethods(
        _ paymentMethods: [PaymentOption]
    ) -> [PaymentOption]
}
