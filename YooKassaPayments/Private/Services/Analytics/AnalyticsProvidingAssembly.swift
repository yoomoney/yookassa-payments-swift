enum AnalyticsProvidingAssembly {

    static func makeAnalyticsProvider(
        testModeSettings: TestModeSettings?
    ) -> AnalyticsProviding {
        let keyValueStoring: KeyValueStoring
        switch testModeSettings {
        case .some(let testModeSettings):
            keyValueStoring = KeyValueStoringAssembly.makeKeychainStorageMock(
                testModeSettings: testModeSettings
            )

        case .none:
            keyValueStoring = KeyValueStoringAssembly.makeKeychainStorage()
        }
        let analyticsProvider = AnalyticsProvider(
            keyValueStoring: keyValueStoring
        )
        return analyticsProvider
    }
}
