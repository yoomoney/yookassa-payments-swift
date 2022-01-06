import YooKassaPaymentsApi

protocol BankCardRepeatInteractorInput {
    func fetchPaymentMethod(paymentMethodId: String)
    func tokenize(
        amount: MonetaryAmount,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodId: String,
        csc: String
    )

    func fetchPaymentMethods()
    func track(event: AnalyticsEvent)
    func analyticsAuthType() -> AnalyticsEvent.AuthType
}

protocol BankCardRepeatInteractorOutput: AnyObject {
    func didFetchPaymentMethod(_ paymentMethod: PaymentMethod)
    func didFailFetchPaymentMethod(_ error: Error)

    func didTokenize(_ tokens: Tokens)
    func didFailTokenize(_ error: Error)

    func didFetchPaymentMethods(_ paymentMethods: [PaymentOption])
    func didFetchPaymentMethods(_ error: Error)
}
