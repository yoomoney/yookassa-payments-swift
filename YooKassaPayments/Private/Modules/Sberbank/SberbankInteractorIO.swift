protocol SberbankInteractorInput: AnalyticsTrack {
    func tokenizeSberbank(
        phoneNumber: String
    )

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
