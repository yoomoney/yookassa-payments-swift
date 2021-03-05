import YooMoneyCoreApi

enum ApiSessionAssembly {
    static func makeApiSession(
        isLoggingEnabled: Bool
    ) -> ApiSession {
        let configuration: URLSessionConfiguration = .default
        configuration.httpAdditionalHeaders = [
            "User-Agent": UserAgentFactory.makeHeaderValue(),
        ]
        let session = ApiSession(
            hostProvider: HostProviderAssembly.makeHostProvider(),
            configuration: configuration,
            logger: isLoggingEnabled ? ApiLogger() : nil
        )

        let isDevHost = KeyValueStoringAssembly.makeSettingsStorage().getBool(for: Settings.Keys.devHost) ?? false

        if isDevHost {
            session.taskDidReceiveChallengeWithCompletion = { (session, challenge, completionHandler) in
                if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
                   let trust = challenge.protectionSpace.serverTrust {
                    let credential = URLCredential(trust: trust)
                    completionHandler(.useCredential, credential)
                }
            }
        }

        return session
    }
}
