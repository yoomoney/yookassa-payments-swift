import class YandexCheckoutPaymentsApi.PaymentOption

protocol YandexAuthInteractorInput: class, AnalyticsTrackable {
    func authorizeInYandex()
    func fetchYamoneyPaymentMethods()
}

protocol YandexAuthInteractorOutput: class {
    func didAuthorizeInYandex(token: String)
    func didAuthorizeInYandex(error: Error)

    func didFetchYamoneyPaymentMethods(_ paymentMethods: [PaymentOption])
    func didFetchYamoneyPaymentMethods(_ error: Error)
}
