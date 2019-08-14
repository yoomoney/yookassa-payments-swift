enum AnalyticsProvidingAssembly {

    static func makeAnalyticsProvider(isLoggingEnabled: Bool,
                                      testModeSettings: TestModeSettings?) -> AnalyticsProviding {
        let authorizationService = AuthorizationProcessingAssembly
            .makeService(isLoggingEnabled: isLoggingEnabled,
                         testModeSettings: testModeSettings)
        let analyticsProvider = AnalyticsProvider(authorizationService: authorizationService)
        return analyticsProvider
    }
}
