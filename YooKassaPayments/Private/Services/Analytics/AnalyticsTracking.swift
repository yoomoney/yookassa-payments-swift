protocol AnalyticsTracking {
    func track(name: String, parameters: [String: String]?)
    func resume()
    func pause()
}

extension AnalyticsTracking {
    func track(event: AnalyticsEvent) {
        track(name: event.name, parameters: event.parameters(context: YKSdk.shared.analyticsContext))
    }
}
