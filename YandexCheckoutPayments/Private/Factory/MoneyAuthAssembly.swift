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
            supportEmail: "supp@money.yandex.ru",
            supportPhone: "8(800)250-6699",
            // swiftlint:disable:next force_unwrapping
            supportHelpUrl: URL(string: "https://money.yandex.ru/page?id=536720")!
        )
        return config
    }

    static func makeMoneyAuthCustomization() -> MoneyAuth.Customization {
        let customization = MoneyAuth.Customization(
            restorePasswordEnabled: false,
            userAgreementTitle: §Localized.userAgreementTitle,
            userWithEmailAgreementTitle: §Localized.userWithEmailAgreementTitle,
            emailCheckboxVisible: false,
            emailCheckboxTitle: §Localized.emailCheckboxTitle,
            addEmailTitle: §Localized.addEmailTitle,
            migrationScreenTitle: §Localized.migrationScreenTitle,
            migrationScreenSubtitle: §Localized.migrationScreenSubtitle,
            migrationScreenButtonSubtitle: §Localized.migrationScreenButtonSubtitle,
            hardMigrationScreenTitle: §Localized.hardMigrationScreenTitle,
            hardMigrationScreenSubtitle: §Localized.hardMigrationScreenSubtitle,
            hardMigrationScreenButtonSubtitle: §Localized.hardMigrationScreenButtonSubtitle
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

// MARK: - Localized

private extension MoneyAuthAssembly {
    enum Localized: String {
        // swiftlint:disable line_length
        case userAgreementTitle = "Wallet.Authorization.userAgreementTitle"
        case userWithEmailAgreementTitle = "Wallet.Authorization.userWithEmailAgreementTitle"
        case emailCheckboxTitle = "Wallet.Authorization.emailCheckboxTitle"
        case addEmailTitle = "Wallet.Authorization.addEmailTitle"
        case migrationScreenTitle = "Wallet.Authorization.migrationScreenTitle"
        case migrationScreenSubtitle = "Wallet.Authorization.migrationScreenSubtitle"
        case migrationScreenButtonSubtitle = "Wallet.Authorization.migrationScreenButtonSubtitle"
        case hardMigrationScreenTitle = "Wallet.Authorization.hardMigrationScreenTitle"
        case hardMigrationScreenSubtitle = "Wallet.Authorization.hardMigrationScreenSubtitle"
        case hardMigrationScreenButtonSubtitle = "Wallet.Authorization.hardMigrationScreenButtonSubtitle"
        // swiftlint:enable line_length
    }
}
