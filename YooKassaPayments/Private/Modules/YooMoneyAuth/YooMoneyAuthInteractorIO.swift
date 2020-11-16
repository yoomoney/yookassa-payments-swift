import class YooKassaPaymentsApi.PaymentOption

protocol YooMoneyAuthInteractorInput: class, AnalyticsTrackable {
    func fetchYamoneyPaymentMethods(
        moneyCenterAuthToken: String,
        walletDisplayName: String?
    )
}

protocol YooMoneyAuthInteractorOutput: class {
    func didFetchYamoneyPaymentMethods(_ paymentMethods: [PaymentOption])
    func didFetchYamoneyPaymentMethods(_ error: Error)
}
