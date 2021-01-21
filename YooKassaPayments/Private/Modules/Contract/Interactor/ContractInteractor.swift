final class ContractInteractor {

    // MARK: - Init data

    fileprivate let analyticsService: AnalyticsService
    fileprivate let analyticsProvider: AnalyticsProvider

    // MARK: - Init

    init(
        analyticsService: AnalyticsService,
        analyticsProvider: AnalyticsProvider
    ) {
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
