protocol AnalyticsService {
    func start()
    func stop()
    func trackEvent(_ event: AnalyticsEvent)
    func trackEventNamed(_ name: String, parameters: [String: String]?)
}
