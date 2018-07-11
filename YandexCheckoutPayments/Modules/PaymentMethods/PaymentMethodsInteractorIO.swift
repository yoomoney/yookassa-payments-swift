import YandexCheckoutPaymentsApi

protocol PaymentMethodsInteractorInput: AnalyticsTrackable, AnalyticsProviding {
    func fetchPaymentMethods()
    func getYandexDisplayName() -> String?
}

protocol PaymentMethodsInteractorOutput: class {
    func didFetchPaymentMethods(_ paymentMethods: [PaymentOption])
    func didFetchPaymentMethods(_ error: Error)
}
