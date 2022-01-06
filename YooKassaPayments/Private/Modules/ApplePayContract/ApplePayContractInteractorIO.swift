protocol ApplePayContractInteractorInput {
    func tokenize(paymentData: String, savePaymentMethod: Bool, amount: MonetaryAmount)
    func track(event: AnalyticsEvent)
    func analyticsAuthType() -> AnalyticsEvent.AuthType
}

protocol ApplePayContractInteractorOutput: AnyObject {
    func didTokenize(_ token: Tokens)
    func failTokenize(_ error: Error)
}
