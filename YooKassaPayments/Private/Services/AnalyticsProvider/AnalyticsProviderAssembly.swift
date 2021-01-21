enum AnalyticsProviderAssembly {
    static func makeProvider(
        testModeSettings: TestModeSettings?
    ) -> AnalyticsProvider {
        let keyValueStoring: KeyValueStoring

        switch testModeSettings {
        case .some(let testModeSettings):
            keyValueStoring = KeyValueStoringAssembly.makeKeychainStorageMock(
                testModeSettings: testModeSettings
            )

        case .none:
            keyValueStoring = KeyValueStoringAssembly.makeKeychainStorage()
        }

        return AnalyticsProviderImpl(
            keyValueStoring: keyValueStoring
        )
    }
}
