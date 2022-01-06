import Foundation

enum ConfigServiceAssembly {
    static func make(isLoggingEnabled: Bool) -> ConfigService {
        ConfigServiceImpl(
            session: ApiSessionAssembly.makeApiSession(isLoggingEnabled: isLoggingEnabled),
            loginEnabled: isLoggingEnabled
        )
    }
}
