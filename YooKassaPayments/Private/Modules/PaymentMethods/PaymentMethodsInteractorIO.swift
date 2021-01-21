import YooKassaPaymentsApi

protocol PaymentMethodsInteractorInput: AnalyticsTrack, AnalyticsProvider {
    func fetchPaymentMethods()
    func getWalletDisplayName() -> String?
}

protocol PaymentMethodsInteractorOutput: class {
    func didFetchPaymentMethods(_ paymentMethods: [PaymentOption])
    func didFetchPaymentMethods(_ error: Error)
}
