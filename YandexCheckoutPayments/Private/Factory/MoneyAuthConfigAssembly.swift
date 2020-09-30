import MoneyAuth

enum MoneyAuthConfigAssembly {
    static func makeMoneyAuthConfig(
        clientId: String,
        yxOauthClientId: String?
    ) -> MoneyAuth.Config {

        let keyValueStorage = KeyValueStoringAssembly.makeSettingsStorage()
        let isDevHost = keyValueStorage.getBool(for: Settings.Keys.devHost) ?? false

        let authenticationChallengeHandler = makeAuthenticationChallengeHandler(
            isDevHost: isDevHost
        )

        let config = MoneyAuth.Config(
            origin: .wallet,
            clientId: clientId,
            host: makeHost(),
            isDevHost: isDevHost,
            loggingEnabled: true,
            authenticationChallengeHandler: authenticationChallengeHandler,
            isPasswordRecoveryEnabled: false,
            setEmailSwitchTitle: nil,
            setPhoneSwitchTitle: nil,
            userAgreement: nil,
            userWithEmailAgreement: nil,
            setEmailScreenSubtitle: "setEmailScreenSubtitle",
            migrationScreenTitle: "migrationScreenTitle",
            migrationScreenSubtitle: "migrationScreenSubtitle",
            supportEmail: "supportEmail",
            // TODO: Make yxOauthClientId optional
            yxOauthClientId: yxOauthClientId ?? ""
        )
        return config
    }

    private static func makeAuthenticationChallengeHandler(
        isDevHost: Bool
    ) -> AuthenticationChallengeHandler? {
        guard isDevHost == true else { return nil }

        let authenticationChallengeHandler: AuthenticationChallengeHandler = { session, challenge, completionHandler in
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.performDefaultHandling, nil)
                return
            }
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }

        return authenticationChallengeHandler
    }

    private static func makeHost() -> String {
        let hostProvider = HostProviderAssembly.makeHostProvider()
        let _host = try? hostProvider.host(
            for: GlobalConstants.Hosts.moneyAuth
        )
        guard let host = _host else {
            assertionFailure("Unknown host for key \(GlobalConstants.Hosts.moneyAuth)")
            return ""
        }
        return host
    }
}
