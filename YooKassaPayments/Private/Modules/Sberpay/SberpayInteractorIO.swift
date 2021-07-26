protocol SberpayInteractorInput: AnalyticsTrack {
    func tokenizeSberpay()

    func makeTypeAnalyticsParameters() -> (
        authType: AnalyticsEvent.AuthType,
        tokenType: AnalyticsEvent.AuthTokenType?
    )
}

protocol SberpayInteractorOutput: AnyObject {
    func didTokenize(
        _ data: Tokens
    )
    func didFailTokenize(
        _ error: Error
    )
}
