import YooMoneyCoreApi

enum ApiSessionAssembly {
    static func makeApiSession(isLoggingEnabled: Bool) -> ApiSession {
        let configuration: URLSessionConfiguration = .default
        configuration.httpAdditionalHeaders = [
            "User-Agent": UserAgentFactory.makeHeaderValue(),
        ]
        let session = ApiSession(
            hostProvider: HostProviderAssembly.makeHostProvider(),
            configuration: configuration,
            logger: isLoggingEnabled ? ApiLogger() : nil
        )

        let isDevHost = KeyValueStoringAssembly.makeUserDefaultsStorage().getBool(for: Settings.Keys.devHost) ?? false

        if isDevHost {
            session.taskDidReceiveChallengeWithCompletion = Self.challengeHandler()
        }

        return session
    }

    typealias ChallengeHandler = (
        URLSession,
        URLAuthenticationChallenge,
        @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) -> Void

    static func challengeHandler() -> ChallengeHandler {
        return { (session, challenge, completion) in
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
               let trust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: trust)
                completion(.useCredential, credential)
            }
        }
    }
}
