import YooKassaPaymentsApi

protocol PaymentMethodHandlerService {
    func filterPaymentMethods(
        _ paymentMethods: [PaymentOption]
    ) -> [PaymentOption]
}
