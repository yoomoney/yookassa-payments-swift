import YandexMoneyCoreApi

enum ApiSessionAssembly {
    static func makeApiSession() -> ApiSession {
        let session = ApiSession(hostProvider: HostProviderAssembly.makeHostProvider(),
                                 logger: nil)
        return session
    }
}
