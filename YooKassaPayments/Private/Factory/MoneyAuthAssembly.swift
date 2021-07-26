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
            userAgreementTitle: Localized.userAgreementTitle,
            userWithEmailAgreementTitle: Localized.userWithEmailAgreementTitle,
            emailCheckboxVisible: Constants.emailCheckboxVisible,
            emailCheckboxTitle: Localized.emailCheckboxTitle,
            addEmailTitle: Localized.addEmailTitle,
            migrationScreenTitle: Localized.migrationScreenTitle,
            migrationScreenSubtitle: Localized.migrationScreenSubtitle,
            migrationScreenButtonSubtitle: Localized.migrationScreenButtonSubtitle,
            hardMigrationScreenTitle: Localized.hardMigrationScreenTitle,
            hardMigrationScreenSubtitle: Localized.hardMigrationScreenSubtitle,
            hardMigrationScreenButtonSubtitle: Localized.hardMigrationScreenButtonSubtitle,
            migrationBannerVisible: Constants.migrationBannerVisible,
            migrationBannerText: Localized.migrationBannerText,
            migrationBannerButtonText: Localized.migrationBannerButtonText,
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
    enum Localized {
        // swiftlint:disable line_length
        static let userAgreementTitle = NSLocalizedString(
            "Wallet.Authorization.userAgreementTitle",
            bundle: Bundle.framework,
            value: "Нажимая кнопку, я подтверждаю осведомлённость и согласие <a href=\\\"https://yoomoney.ru/page?id=525698%5C\\\">со всеми юридическими условиями</a> и с тем, что если я не подключу информирование об операциях на почту или телефон, единственным каналом информирования будет история моих операций — на сайте и в приложении ЮMoney",
            comment: "Текст на экране про миграцию, который после нажатия на немигрированный аккаунт на экране выбора аккаунта https://yadi.sk/i/_IMGLswOravIOw"
        )
        static let userWithEmailAgreementTitle = NSLocalizedString(
            "Wallet.Authorization.userWithEmailAgreementTitle",
            bundle: Bundle.framework,
            value: "Нажимая кнопку, я подтверждаю осведомлённость и согласие <a href=\\\"https://yoomoney.ru/page?id=525698%5C\\\">со всеми юридическими условиями</a>",
            comment: "Текст с ссылкой под кнопкой на экране про миграцию, который после нажатия на немигрированный аккаунт на экране выбора аккаунта https://yadi.sk/i/_IMGLswOravIOw"
        )
        static let emailCheckboxTitle = NSLocalizedString(
            "Wallet.Authorization.emailCheckboxTitle",
            bundle: Bundle.framework,
            value: "Хочу получать новости сервиса, скидки, опросы: максимум раз в неделю",
            comment: "Текст условий сервиса с ссылкой на экране установки пароля для пользователя c установленной почтой https://yadi.sk/i/DgL-5V4hQL15WQ"
        )
        static let addEmailTitle = NSLocalizedString(
            "Wallet.Authorization.addEmailTitle",
            bundle: Bundle.framework,
            value: "Для чеков и уведомлений",
            comment: "Текст условий сервиса с ссылкой на экране установки пароля для пользователя без установленной почты https://yadi.sk/i/DgL-5V4hQL15WQ"
        )
        static let migrationScreenTitle = NSLocalizedString(
            "Wallet.Authorization.migrationScreenTitle",
            bundle: Bundle.framework,
            value: "Зачем куда-то переходить?",
            comment: "Заголовок экрана про миграцию, который после нажатия на немигрированный аккаунт на экране выбора аккаунта https://yadi.sk/i/_IMGLswOravIOw"
        )
        static let migrationScreenSubtitle = NSLocalizedString(
            "Wallet.Authorization.migrationScreenSubtitle",
            bundle: Bundle.framework,
            value: "Потому что теперь кошелёк — в ЮMoney, отдельно от аккаунта в Яндексе.\\n\\n— Что останется как раньше: номер кошелька, ваши настройки, условия использования.\\n\\n— Что поменяется: вместо логина (как в Яндексе) у вас будет почта или телефон. Пароль тоже можно обновить.\\n\\n— Сейчас нужно: войти в аккаунт Яндекса, где есть кошелёк.",
            comment: "Текст с ссылкой под кнопкой на экране про миграцию, который после нажатия на большой баннер на экране ввода почты/телефона при авторизации https://yadi.sk/i/_IMGLswOravIOw"
        )
        static let migrationScreenButtonSubtitle = NSLocalizedString(
            "Wallet.Authorization.migrationScreenButtonSubtitle",
            bundle: Bundle.framework,
            value: "На лимиты, комиссии и остальные условия использования кошелька это никак не влияет: <a href=\\\"https://new.yoomoney.ru\\\">вот подробности</a>",
            comment: "Текст на экране про миграцию, который после нажатия на большой баннер на экране ввода почты/телефона при авторизации https://yadi.sk/i/_IMGLswOravIOw"
        )
        static let hardMigrationScreenTitle = NSLocalizedString(
            "Wallet.Authorization.hardMigrationScreenTitle",
            bundle: Bundle.framework,
            value: "Пора перейти в ЮMoney",
            comment: "Заголовок экрана про миграцию, который после нажатия на большой баннер на экране ввода почты/телефона при авторизации https://yadi.sk/i/_IMGLswOravIOw"
        )
        static let hardMigrationScreenSubtitle = NSLocalizedString(
            "Wallet.Authorization.hardMigrationScreenSubtitle",
            bundle: Bundle.framework,
            value: "Раньше вы заходили в кошелёк с логином и паролем Яндекса, теперь нужен профиль ЮMoney.\\nСейчас поможем его получить:\\n\\n— вы зайдёте с логином и паролем Яндекса,\\n— разрешите ЮMoney доступ к имени и почте,\\n— придумаете новый пароль.\\n\\nУ вас появится профиль ЮMoney с прежним кошельком внутри.\\nДля входа — почта и пароль, для подтверждений — смс-коды.",
            comment: "Текст под полем ввода почты на экране ввода почты https://yadi.sk/i/8BSuo7q_6CJzbg"
        )
        static let hardMigrationScreenButtonSubtitle = NSLocalizedString(
            "Wallet.Authorization.hardMigrationScreenButtonSubtitle",
            bundle: Bundle.framework,
            value: "На лимиты, комиссии и остальные условия использования кошелька это никак не влияет: <a href=\\\"https://new.yoomoney.ru/\\\">вот подробности </a>",
            comment: "Текст свитча согласия на рассылку на экране ввода почты https://yadi.sk/i/8BSuo7q_6CJzbg"
        )
        static let migrationBannerText = NSLocalizedString(
            "Wallet.Authorization.migrationBannerText",
            bundle: Bundle.framework,
            value: "Если вы регистрировались до 21 октября — нужно перейти в ЮMoney",
            comment: "Текст на баннере миграции https://yadi.sk/i/IuBf_A1_uq2zSg"
        )
        static let migrationBannerButtonText = NSLocalizedString(
            "Wallet.Authorization.migrationBannerButtonText",
            bundle: Bundle.framework,
            value: "Подробнее",
            comment: "Текст на кнопке баннера миграции https://yadi.sk/i/IuBf_A1_uq2zSg"
        )
        // swiftlint:enable line_length
    }
}
