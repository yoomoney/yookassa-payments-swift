import YandexCheckoutWalletApi

enum AuthorizationProcessingAssembly {
    static func makeService(testModeSettings: TestModeSettings?) -> AuthorizationProcessing {
        let yandexLoginService = YandexLoginProcessingAssembly.makeService()
        let yamoneyLoginService = YamoneyLoginAssembly.makeYamoneyLoginService(testModeSettings: testModeSettings)
        let deviceInfoService = DeviceInfoProviderAssembly.makeDeviceInfoProvider()

        let tokenStorage: KeyValueStoring
        switch testModeSettings {
        case .some(let testModeSettings):
            tokenStorage = KeyValueStoringAssembly.makeMockKeychainStorage(testModeSettings: testModeSettings)
        case .none:
            tokenStorage = KeyValueStoringAssembly.makeKeychainStorage()
        }

        let authorizationMediator = AuthorizationMediator(tokenStorage: tokenStorage,
                                                          yandexLoginService: yandexLoginService,
                                                          yamoneyLoginService: yamoneyLoginService,
                                                          deviceInfoService: deviceInfoService)
        return authorizationMediator
    }
}
