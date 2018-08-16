import YandexMoneyCoreApi

enum ApiSessionAssembly {
    static func makeApiSession() -> ApiSession {
        let configuration: URLSessionConfiguration = .default
        configuration.httpAdditionalHeaders = [
            "User-Agent": UserAgentFactory.makeHeaderValue(),
        ]
        let session = ApiSession(hostProvider: HostProviderAssembly.makeHostProvider(),
                                 configuration: configuration,
                                 logger: nil)
        return session
    }
}
