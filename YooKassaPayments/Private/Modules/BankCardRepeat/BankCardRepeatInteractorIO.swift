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
}

protocol BankCardRepeatInteractorOutput: class {
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
}
