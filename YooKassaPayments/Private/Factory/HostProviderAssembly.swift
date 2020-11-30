import YooMoneyCoreApi

enum HostProviderAssembly {
    static func makeHostProvider() -> YooMoneyCoreApi.HostProvider {
        return HostProvider(settingStorage: KeyValueStoringAssembly.makeSettingsStorage())
    }
}
