protocol SberbankInteractorInput {
    func tokenizeSberbank(phoneNumber: String, savePaymentMethod: Bool)

    func analyticsAuthType() -> AnalyticsEvent.AuthType
    func track(event: AnalyticsEvent)
}

protocol SberbankInteractorOutput: AnyObject {
    func didTokenize(_ data: Tokens)
    func didFailTokenize(_ error: Error)
}
