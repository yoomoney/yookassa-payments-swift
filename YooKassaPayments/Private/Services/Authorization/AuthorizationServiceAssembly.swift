import MoneyAuth

enum AuthorizationServiceAssembly {
    static func makeService(
        isLoggingEnabled: Bool,
        testModeSettings: TestModeSettings?,
        moneyAuthClientId: String?
    ) -> AuthorizationService {
        let tokenStorage: KeyValueStoring
        switch testModeSettings {
        case let .some(testModeSettings):
            tokenStorage = KeyValueStoringAssembly.makeKeychainStorageMock(
                testModeSettings: testModeSettings
            )
        case .none:
            tokenStorage = KeyValueStoringAssembly.makeKeychainStorage()
        }

        let walletLoginService = WalletLoginServiceAssembly.makeService(
            isLoggingEnabled: isLoggingEnabled,
            testModeSettings: testModeSettings
        )
        let deviceInfoService = DeviceInfoServiceAssembly.makeService()
        let settingsStorage = KeyValueStoringAssembly.makeSettingsStorage()

        var moneyAuthRevokeTokenService: MoneyAuth.RevokeTokenService?
        if let moneyAuthClientId = moneyAuthClientId {
            let moneyAuthConfig = MoneyAuthAssembly.makeMoneyAuthConfig(
                moneyAuthClientId: moneyAuthClientId,
                loggingEnabled: isLoggingEnabled
            )
            moneyAuthRevokeTokenService = RevokeTokenServiceFactory.makeService(
                config: moneyAuthConfig
            )
        }

        return AuthorizationServiceImpl(
            tokenStorage: tokenStorage,
            walletLoginService: walletLoginService,
            deviceInfoService: deviceInfoService,
            settingsStorage: settingsStorage,
            moneyAuthRevokeTokenService: moneyAuthRevokeTokenService
        )
    }
}
