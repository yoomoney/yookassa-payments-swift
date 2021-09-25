protocol SberbankInteractorInput: AnalyticsTrack {
    func tokenizeSberbank(phoneNumber: String, savePaymentMethod: Bool)

    func makeTypeAnalyticsParameters() -> (
        authType: AnalyticsEvent.AuthType,
        tokenType: AnalyticsEvent.AuthTokenType?
    )
}

protocol SberbankInteractorOutput: AnyObject {
    func didTokenize(
        _ data: Tokens
    )
    func didFailTokenize(
        _ error: Error
    )
}
