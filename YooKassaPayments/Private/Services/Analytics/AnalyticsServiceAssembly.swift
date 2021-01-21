enum AnalyticsServiceAssembly {
    static func makeService(
        isLoggingEnabled: Bool
    ) -> AnalyticsService {
        return AnalyticsServiceImpl(
            isLoggingEnabled: isLoggingEnabled
        )
    }
}
