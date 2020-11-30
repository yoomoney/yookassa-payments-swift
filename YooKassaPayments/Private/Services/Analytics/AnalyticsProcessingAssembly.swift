enum AnalyticsProcessingAssembly {
    static func makeAnalyticsService(isLoggingEnabled: Bool) -> AnalyticsProcessing {
        return AnalyticsService(isLoggingEnabled: isLoggingEnabled)
    }
}
