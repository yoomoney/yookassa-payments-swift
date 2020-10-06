import MoneyAuth

enum MoneyAuthAssembly {
    static func makeMoneyAuthConfig(
        clientId: String,
        yxOauthClientId: String?,
        loggingEnabled: Bool
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
            loggingEnabled: loggingEnabled,
            authenticationChallengeHandler: authenticationChallengeHandler,
            yxOauthClientId: yxOauthClientId,
            supportEmail: "supportEmail",
            supportPhone: "supportPhone",
            // swiftlint:disable force_unwrapping
            supportHelpUrl: URL(string: "https://google.com")!
            // swiftlint:enable force_unwrapping
        )
        return config
    }

    static func makeMoneyAuthCustomization() -> MoneyAuth.Customization {
        let customization = MoneyAuth.Customization(
            restorePasswordEnabled: true,
            userAgreementTitle: "userAgreementTitle",
            userWithEmailAgreementTitle: "userWithEmailAgreementTitle",
            emailCheckboxVisible: true,
            emailCheckboxTitle: "emailCheckboxTitle",
            addEmailTitle: "addEmailTitle",
            migrationScreenTitle: "migrationScreenTitle",
            migrationScreenSubtitle: "migrationScreenSubtitle",
            migrationScreenButtonSubtitle: "migrationScreenButtonSubtitle",
            hardMigrationScreenTitle: "hardMigrationScreenTitle",
            hardMigrationScreenSubtitle: "hardMigrationScreenSubtitle",
            hardMigrationScreenButtonSubtitle: "hardMigrationScreenButtonSubtitle"
        )
        return customization
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
