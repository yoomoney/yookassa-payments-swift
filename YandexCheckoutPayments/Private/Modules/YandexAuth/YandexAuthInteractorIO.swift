import class YandexCheckoutPaymentsApi.PaymentOption

protocol YandexAuthInteractorInput: class, AnalyticsTrackable {
    func fetchYamoneyPaymentMethods(
        moneyCenterAuthToken: String
    )
}

protocol YandexAuthInteractorOutput: class {
    func didFetchYamoneyPaymentMethods(_ paymentMethods: [PaymentOption])
    func didFetchYamoneyPaymentMethods(_ error: Error)
}
