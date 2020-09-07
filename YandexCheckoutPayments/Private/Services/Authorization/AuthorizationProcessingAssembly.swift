import YandexCheckoutWalletApi

enum AuthorizationProcessingAssembly {
    static func makeService(isLoggingEnabled: Bool,
                            testModeSettings: TestModeSettings?) -> AuthorizationProcessing {
        let yamoneyLoginService = YamoneyLoginAssembly
            .makeYamoneyLoginService(isLoggingEnabled: isLoggingEnabled,
                                     testModeSettings: testModeSettings)
        let deviceInfoService = DeviceInfoProviderAssembly.makeDeviceInfoProvider()
        let settingsStorage = KeyValueStoringAssembly.makeSettingsStorage()

        let tokenStorage: KeyValueStoring
        switch testModeSettings {
        case .some(let testModeSettings):
            tokenStorage = KeyValueStoringAssembly.makeMockKeychainStorage(testModeSettings: testModeSettings)
        case .none:
            tokenStorage = KeyValueStoringAssembly.makeKeychainStorage()
        }

        let authorizationMediator = AuthorizationMediator(
            tokenStorage: tokenStorage,
            yamoneyLoginService: yamoneyLoginService,
            deviceInfoService: deviceInfoService,
            settingsStorage: settingsStorage
        )
        return authorizationMediator
    }
}
