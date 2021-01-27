import YooKassaPaymentsApi

protocol PaymentMethodsInteractorInput: AnalyticsTrack, AnalyticsProvider {
    func fetchPaymentMethods()
}

protocol PaymentMethodsInteractorOutput: class {
    func didFetchPaymentMethods(_ paymentMethods: [PaymentOption])
    func didFetchPaymentMethods(_ error: Error)
}
