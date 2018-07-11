final class ContractInteractor {

    fileprivate let analyticsService: AnalyticsProcessing
    fileprivate let analyticsProvider: AnalyticsProviding

    init(analyticsService: AnalyticsProcessing,
         analyticsProvider: AnalyticsProviding) {
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider
    }
}

// MARK: - ContractInteractorInput
extension ContractInteractor: ContractInteractorInput {

    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }

    func makeTypeAnalyticsParameters() -> (authType: AnalyticsEvent.AuthType,
                                           tokenType: AnalyticsEvent.AuthTokenType?) {
        return analyticsProvider.makeTypeAnalyticsParameters()
    }
}
