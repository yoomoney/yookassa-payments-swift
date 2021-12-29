import YooMoneyCoreApi

enum HostProviderAssembly {
    static func makeHostProvider() -> YooMoneyCoreApi.HostProvider {
        return HostProvider(
            settingStorage: KeyValueStoringAssembly.makeUserDefaultsStorage(),
            configStorage: KeyValueStoringAssembly.makeSettingsStorage(),
            defaultConfig: ConfigMediatorImpl.defaultConfig
        )
    }
}
