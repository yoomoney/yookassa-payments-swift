protocol AnalyticsService {
    func start()
    func stop()
    func trackEvent(_ event: AnalyticsEvent)
}
