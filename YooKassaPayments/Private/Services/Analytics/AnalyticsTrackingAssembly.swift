enum AnalyticsTrackingAssembly {
    static func make(isLoggingEnabled: Bool) -> AnalyticsTracking {
        CommonTracker(isLoggingEnabled: isLoggingEnabled)
    }
}
