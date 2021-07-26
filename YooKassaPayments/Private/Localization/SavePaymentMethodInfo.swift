enum SavePaymentMethodInfoLocalization {
    // swiftlint:disable line_length
    enum Wallet {
        static let header = NSLocalizedString(
            "SavePaymentMethodInfo.Wallet.Header",
            bundle: Bundle.framework,
            value: "Разрешение списывать деньги без вашего участия",
            comment: "Заголовок на экране разрешения списывать деньги магазином с кошелька https://yadi.sk/i/4MbCtrW4qrtDcQ"
        )
        static let body = NSLocalizedString(
            "SavePaymentMethodInfo.Wallet.Body",
            bundle: Bundle.framework,
            value: "Это значит, что вы разрешаете ЮMoney списывать деньги с кошелька по запросу магазина — без дополнительного подтверждения с вашей стороны. Отменить такие списания можно в любой момент — в настройках кошелька (на сайте ЮMoney).",
            comment: "Текст на экране разрешения списывать деньги магазином с кошелька https://yadi.sk/i/4MbCtrW4qrtDcQ"
        )

    }
    enum BankCard {
        static let header = NSLocalizedString(
            "SavePaymentMethodInfo.BankCard.Header",
            bundle: Bundle.framework,
            value: "Разрешение списывать деньги по запросу магазина",
            comment: "Заголовок на экране разрешения списывать деньги магазином с банковской карты https://yadi.sk/i/QOSvfo9hsOPs9Q"
        )
        static let body = NSLocalizedString(
            "SavePaymentMethodInfo.BankCard.Body",
            bundle: Bundle.framework,
            value: "Это значит, что вы разрешаете ЮMoney списывать деньги по запросу магазина без отдельного подтверждения — с этой карты или с новой, при перевыпуске (если ваш банк умеет автоматически обновлять данные).\\n\\nОтменить привязку можно в любой момент — через службу поддержки магазина.",
            comment: "Текст на экране разрешения списывать деньги магазином с банковской карты https://yadi.sk/i/QOSvfo9hsOPs9Q"
        )
    }
    // swiftlint:enable line_length
}
