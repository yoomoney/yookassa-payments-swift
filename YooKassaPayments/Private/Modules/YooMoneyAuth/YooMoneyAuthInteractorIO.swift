import class YooKassaPaymentsApi.PaymentOption

protocol YooMoneyAuthInteractorInput: class, AnalyticsTrack {
    func fetchYooMoneyPaymentMethods(
        moneyCenterAuthToken: String,
        walletDisplayName: String?
    )
}

protocol YooMoneyAuthInteractorOutput: class {
    func didFetchYooMoneyPaymentMethods(
        _ paymentMethods: [PaymentOption]
    )
    func didFetchYooMoneyPaymentMethods(
        _ error: Error
    )
}
