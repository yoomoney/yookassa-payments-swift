enum AnalyticsProvidingAssembly {

    static func makeAnalyticsProvider(testModeSettings: TestModeSettings?) -> AnalyticsProviding {
        let authorizationService = AuthorizationProcessingAssembly.makeService(testModeSettings: testModeSettings)
        let analyticsProvider = AnalyticsProvider(authorizationService: authorizationService)
        return analyticsProvider
    }
}
