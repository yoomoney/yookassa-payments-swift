import Foundation

enum ConfigMediatorAssembly {
    static func make(isLoggingEnabled: Bool) -> ConfigMediator {
        return ConfigMediatorImpl(
            service: ConfigServiceAssembly.make(isLoggingEnabled: isLoggingEnabled),
            storage: KeyValueStoringAssembly.makeSettingsStorage()
        )
    }
}
