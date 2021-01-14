import MoneyAuth
import YooKassaWalletApi

enum AuthorizationServiceAssembly {
    static func makeService(
        isLoggingEnabled: Bool,
        testModeSettings: TestModeSettings?,
        moneyAuthClientId: String?
    ) -> AuthorizationService {
        let tokenStorage: KeyValueStoring
        switch testModeSettings {
        case let .some(testModeSettings):
            tokenStorage = KeyValueStoringAssembly.makeMockKeychainStorage(
                testModeSettings: testModeSettings
            )
        case .none:
            tokenStorage = KeyValueStoringAssembly.makeKeychainStorage()
        }

        let walletLoginService = WalletLoginAssembly.makeWalletLoginService(
            isLoggingEnabled: isLoggingEnabled,
            testModeSettings: testModeSettings
        )
        let deviceInfoService = DeviceInfoProviderAssembly.makeDeviceInfoProvider()
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
