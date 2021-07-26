// MARK: - Localization

enum CommonLocalized {
    // swiftlint:disable line_length

    enum Contract {
        static let next = NSLocalizedString(
            "Contract.next",
            bundle: Bundle.framework,
            value: "Продолжить",
            comment: "Кнопка продолжить на контрактах https://yadi.sk/i/Ri9RjHDtilycWw"
        )
        static let fee = NSLocalizedString(
            "Contract.fee",
            bundle: Bundle.framework,
            value: "Включая комиссию",
            comment: "Текст на контракте `Включая комиссию` https://yadi.sk/i/Ri9RjHDtilycWw"
        )
    }

    enum PlaceholderView {
        static let buttonTitle = NSLocalizedString(
            "Common.PlaceholderView.buttonTitle",
            bundle: Bundle.framework,
            value: "Повторить",
            comment: "Текст кнопки на Placeholder `Повторить`"
        )
        static let text = NSLocalizedString(
            "Common.PlaceholderView.text",
            bundle: Bundle.framework,
            value: "Попробуйте повторить чуть позже.",
            comment: "Текст на Placeholder `Попробуйте повторить чуть позже.`"
        )
    }

    enum BankCardView {
        static let inputPanHint = NSLocalizedString(
            "BankCardView.inputPanHint",
            bundle: Bundle.framework,
            value: "Номер карты",
            comment: "Текст `Номер карты` при вводе данных банковской карты https://yadi.sk/i/Z2oi1Uun7nS-jA"
        )
        static let inputPanPlaceholder = NSLocalizedString(
            "BankCardView.inputPanPlaceholder",
            bundle: Bundle.framework,
            value: "Введите или отсканируйте",
            comment: "Текст `Введите или отсканируйте` при вводе данных банковской карты https://yadi.sk/i/Z2oi1Uun7nS-jA"
        )
        static let inputPanPlaceholderWithoutScan = NSLocalizedString(
            "BankCardView.inputPanPlaceholderWithoutScan",
            bundle: Bundle.framework,
            value: "Введите",
            comment: "Текст `Введите` при вводе данных банковской карты в случае если сканирование не доступно https://yadi.sk/i/fbrtpMi0d-k4xw"
        )
        static let inputExpiryDateHint = NSLocalizedString(
            "BankCardView.inputExpiryDateHint",
            bundle: Bundle.framework,
            value: "Срок действия",
            comment: "Текст `Срок действия` при вводе данных банковской карты https://yadi.sk/i/qhizzdr8cAATsw"
        )
        static let inputExpiryDatePlaceholder = NSLocalizedString(
            "BankCardView.inputExpiryDatePlaceholder",
            bundle: Bundle.framework,
            value: "ММ/ГГ",
            comment: "Текст `ММ/ГГ` при вводе данных банковской карты https://yadi.sk/i/qhizzdr8cAATsw"
        )
        static let inputCvcHint = NSLocalizedString(
            "BankCardView.inputCvcHint",
            bundle: Bundle.framework,
            value: "Код",
            comment: "Текст `Код` при вводе данных банковской карты https://yadi.sk/i/qhizzdr8cAATsw"
        )
        static let inputCvcPlaceholder = NSLocalizedString(
            "BankCardView.inputCvcPlaceholder",
            bundle: Bundle.framework,
            value: "CVC",
            comment: "Текст `CVC` при вводе данных банковской карты https://yadi.sk/i/qhizzdr8cAATsw"
        )

        enum BottomHint {
            static let invalidPan = NSLocalizedString(
                "BankCardDataInputView.BottomHint.invalidPan",
                bundle: Bundle.framework,
                value: "Проверьте номер карты",
                comment: "Текст `Проверьте номер карты` при вводе данных банковской карты https://yadi.sk/i/uDMEBEe3DqPboA"
            )
            static let invalidExpiry = NSLocalizedString(
                "BankCardDataInputView.BottomHint.invalidExpiry",
                bundle: Bundle.framework,
                value: "Проверьте месяц и год",
                comment: "Текст `Проверьте месяц и год` при вводе данных банковской карты https://yadi.sk/d/SbMd6T6aj3vyAw"
            )
            static let invalidCvc = NSLocalizedString(
                "BankCardDataInputView.BottomHint.invalidCvc",
                bundle: Bundle.framework,
                value: "Проверьте CVC",
                comment: "Текст `Проверьте CVC` при вводе данных банковской карты https://yadi.sk/i/A49itN4AH9BkHg"
            )
        }
    }

    enum Error {
        static let unknown = NSLocalizedString(
            "Common.Error.unknown",
            bundle: Bundle.framework,
            value: "Что то пошло не так",
            comment: "Текст `Что то пошло не так` https://yadi.sk/i/JapUT2mTEVnTtw"
        )
    }

    enum Alert {
        static let ok = NSLocalizedString(
            "Common.button.ok",
            bundle: Bundle.framework,
            value: "ОК",
            comment: "Текст `ОК` на Alert https://yadi.sk/i/68ImXb9rz31RkQ"
        )
        static let cancel = NSLocalizedString(
            "Common.button.cancel",
            bundle: Bundle.framework,
            value: "Отменить",
            comment: "Текст `Отменить` на Alert https://yadi.sk/i/68ImXb9rz31RkQ"
        )
    }

    enum SaveAuthInApp {
        static let title = NSLocalizedString(
            "Contract.format.saveAuthInApp.title",
            bundle: Bundle.framework,
            value: "Запомнить меня",
            comment: "Текст `Запомнить меня` на экране `ЮMoney` или `Привязанная карта` https://yadi.sk/i/o89CnEUSmNsM7g"
        )
        static let text = NSLocalizedString(
            "Contract.format.saveAuthInApp",
            bundle: Bundle.framework,
            value: "В следующий раз не придётся входить в профиль ЮMoney — можно будет оплатить быстрее",
            comment: "Текст в пункте `Запомнить меня` на экране `ЮMoney` или `Привязанная карта` https://yadi.sk/i/o89CnEUSmNsM7g"
        )
    }

    enum ApplePay {
        static let applePayUnavailableTitle = NSLocalizedString(
            "ApplePayUnavailable.title",
            bundle: Bundle.framework,
            value: "Apple Pay недоступен",
            comment: "По неизвестным нам причинам экран ApplePay не отобразился"
        )
        static let failTokenizeData = NSLocalizedString(
            "Error.ApplePayStrategy.failTokenizeData",
            bundle: Bundle.framework,
            value: "В процессе токенизации ApplePay произошла ошибка",
            comment: "В процессе токенизации ApplePay произошла ошибка https://yadi.sk/i/G9zC-PLLpmuQVw"
        )
    }

    enum SberPay {
        static let title = NSLocalizedString(
            "Sberpay.Contract.Title",
            bundle: Bundle.framework,
            value: "SberPay",
            comment: "Текст `SberPay` https://yadi.sk/i/T-XQGU9NaPMgKA"
        )
    }
    // swiftlint:enable line_length
}
