import YandexCheckoutPaymentsApi

protocol PaymentMethodsInteractorInput: AnalyticsTrackable, AnalyticsProviding {
    func fetchPaymentMethods()
}

protocol PaymentMethodsInteractorOutput: class {
    func didFetchPaymentMethods(_ paymentMethods: [PaymentOption])
    func didFetchPaymentMethods(_ error: Error)
}
