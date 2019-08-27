import YandexCheckoutPaymentsApi

protocol BankCardRepeatInteractorInput: AnalyticsTrackable {
    func fetchPaymentMethod(paymentMethodId: String)
    func tokenize(amount: MonetaryAmount,
                  confirmation: Confirmation,
                  paymentMethodId: String,
                  csc: String)
}

protocol BankCardRepeatInteractorOutput: class {
    func didFetchPaymentMethod(_ paymentMethod: YandexCheckoutPaymentsApi.PaymentMethod)
    func didFailFetchPaymentMethod(_ error: Error)
    func didTokenize(_ tokens: Tokens)
    func didFailTokenize(_ error: Error)
}
