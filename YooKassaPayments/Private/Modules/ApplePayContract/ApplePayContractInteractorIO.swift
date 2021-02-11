protocol ApplePayContractInteractorInput: AnalyticsTrack, AnalyticsProvider {
    func tokenize(
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount
    )
}

protocol ApplePayContractInteractorOutput: class {
    func didTokenize(
        _ token: Tokens
    )
    func failTokenize(
        _ error: Error
    )
}
