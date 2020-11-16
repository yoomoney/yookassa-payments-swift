import MoneyAuth

enum MoneyAuthAssembly {
    static func makeMoneyAuthConfig(
        moneyAuthClientId: String,
        loggingEnabled: Bool
    ) -> MoneyAuth.Config {
        let keyValueStorage = KeyValueStoringAssembly.makeSettingsStorage()
        let isDevHost = keyValueStorage.getBool(for: Settings.Keys.devHost) ?? false
        let authenticationChallengeHandler = makeAuthenticationChallengeHandler(
            isDevHost: isDevHost
        )
        let yxOauthClientId = makeYXOauthClientId(
            isDevHost: isDevHost
        )
        let moneyAuthClientId = makeMoneyAuthClientId(
            currentClientId: moneyAuthClientId,
            isDevHost: isDevHost
        )

        let config = MoneyAuth.Config(
            origin: .wallet,
            clientId: moneyAuthClientId,
            host: makeHost(),
            isDevHost: isDevHost,
            loggingEnabled: loggingEnabled,
            authenticationChallengeHandler: authenticationChallengeHandler,
            yxOauthClientId: yxOauthClientId,
            supportEmail: "support@yoomoney.ru",
            supportPhone: "8 800 250-66-99",
            // swiftlint:disable:next force_unwrapping
            supportHelpUrl: URL(string: "https://yoomoney.ru/page?id=536720")!
        )
        return config
    }

    static func makeMoneyAuthCustomization() -> MoneyAuth.Customization {
        let customization = MoneyAuth.Customization(
            restorePasswordEnabled: Constants.restorePasswordEnabled,
            userAgreementTitle: §Localized.userAgreementTitle,
            userWithEmailAgreementTitle: §Localized.userWithEmailAgreementTitle,
            emailCheckboxVisible: Constants.emailCheckboxVisible,
            emailCheckboxTitle: §Localized.emailCheckboxTitle,
            addEmailTitle: §Localized.addEmailTitle,
            migrationScreenTitle: §Localized.migrationScreenTitle,
            migrationScreenSubtitle: §Localized.migrationScreenSubtitle,
            migrationScreenButtonSubtitle: §Localized.migrationScreenButtonSubtitle,
            hardMigrationScreenTitle: §Localized.hardMigrationScreenTitle,
            hardMigrationScreenSubtitle: §Localized.hardMigrationScreenSubtitle,
            hardMigrationScreenButtonSubtitle: §Localized.hardMigrationScreenButtonSubtitle,
            migrationBannerVisible: Constants.migrationBannerVisible,
            migrationBannerText: §Localized.migrationBannerText,
            migrationBannerButtonText: §Localized.migrationBannerButtonText,
            migrationBannerImageUrl: URL(string: Constants.migrationBannerImageUrl)
        )
        return customization
    }

    private static func makeAuthenticationChallengeHandler(
        isDevHost: Bool
    ) -> AuthenticationChallengeHandler? {
        guard isDevHost == true else { return nil }

        let authenticationChallengeHandler: AuthenticationChallengeHandler = { challenge, completionHandler in
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

    private static func makeYXOauthClientId(
        isDevHost: Bool
    ) -> String {
        return isDevHost
            ? "5bcecea3c35b447aaf8257e1af58d6b3"
            : "80642c11721c49d69d9936de0c265886"
    }

    private static func makeMoneyAuthClientId(
        currentClientId: String,
        isDevHost: Bool
    ) -> String {
        guard isDevHost == false else {
            return "a90r00nd74uqa4f1jbp6dni0tmf9eg6s"
        }
        return currentClientId
    }
}

// MARK: - Constants

private extension MoneyAuthAssembly {
    enum Constants {
        // swiftlint:disable line_length
        static let restorePasswordEnabled = false
        static let emailCheckboxVisible = false
        static let migrationBannerVisible = true
        static let migrationBannerImageUrl = "https://static.yoomoney.ru/files-front/mobile/img/ios_migration_banner_logo.png"
        // swiftlint:enable line_length
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
        case migrationBannerText = "Wallet.Authorization.migrationBannerText"
        case migrationBannerButtonText = "Wallet.Authorization.migrationBannerButtonText"
        // swiftlint:enable line_length
    }
}
