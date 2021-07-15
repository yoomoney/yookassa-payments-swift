import YooKassaPaymentsApi

protocol BankCardRepeatInteractorInput: AnalyticsTrack, AnalyticsProvider {
    func fetchPaymentMethod(
        paymentMethodId: String
    )
    func tokenize(
        amount: MonetaryAmount,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodId: String,
        csc: String
    )

    func fetchPaymentMethods()

    func startAnalyticsService()
    func stopAnalyticsService()
}

protocol BankCardRepeatInteractorOutput: AnyObject {
    func didFetchPaymentMethod(
        _ paymentMethod: PaymentMethod
    )
    func didFailFetchPaymentMethod(
        _ error: Error
    )

    func didTokenize(
        _ tokens: Tokens
    )
    func didFailTokenize(
        _ error: Error
    )

    func didFetchPaymentMethods(
        _ paymentMethods: [PaymentOption]
    )
    func didFetchPaymentMethods(
        _ error: Error
    )
}
