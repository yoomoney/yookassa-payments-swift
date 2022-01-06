protocol SberpayInteractorInput {
    func tokenizeSberpay(savePaymentMethod: Bool)

    func track(event: AnalyticsEvent)
    func analyticsAuthType() -> AnalyticsEvent.AuthType
}

protocol SberpayInteractorOutput: AnyObject {
    func didTokenize(_ data: Tokens)
    func didFailTokenize(_ error: Error)
}
