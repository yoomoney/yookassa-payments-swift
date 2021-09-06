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

    enum CardSettingsDetails {
        static let unbind = NSLocalizedString(
            "card.details.unbind",
            bundle: Bundle.framework,
            value: "Отвязать карту",
            comment: "Текст `Отвязать карту` https://disk.yandex.ru/i/QNJyBrfP52vQOw"
        )
        static let autopaymentPersists = NSLocalizedString(
            "card.details.autopaymentPersists",
            bundle: Bundle.framework,
            value: "После отвязки карты останутся автосписания. Отменить их можно через службу поддержки магазина.",
            comment: "Текст, в информере, о сохранении автоплатежа https://disk.yandex.ru/i/QNJyBrfP52vQOw"
        )
        static let moreInfo = NSLocalizedString(
            "card.details.info.more",
            bundle: Bundle.framework,
            value: "Подробнее",
            comment: "Текст кнопки, в информере, ведущей в подробности https://disk.yandex.ru/i/QNJyBrfP52vQOw"
        )
        static let unwind = NSLocalizedString(
            "card.details.unwind",
            bundle: Bundle.framework,
            value: "Вернуться",
            comment: "Текст, ведущей назад, кнопки https://disk.yandex.ru/i/dcgivhF4QbURwA"
        )
        static let yoocardUnbindDetails = NSLocalizedString(
            "card.details.yoocardUnbindDetails",
            bundle: Bundle.framework,
            value: "Отвязать эту карту можно только в настройках кошелька",
            comment: "Текст, в информере, для карты привязанной к кошельку https://disk.yandex.ru/i/dcgivhF4QbURwA"
        )
        static let autopayInfoTitle = NSLocalizedString(
            "card.details.info.autopay.title",
            bundle: Bundle.framework,
            value: "Как работают автоматические списания",
            comment: "Заголовок информации о работе автосписания https://disk.yandex.ru/i/r9l5HObi2jZy6A"
        )
        static let autopayInfoDetails = NSLocalizedString(
            "card.details.info.autopay.details",
            bundle: Bundle.framework,
            value: "Если вы согласитесь на автосписания, мы привяжем банковскую карту к магазину. После этого магазин сможет присылать запросы на автоматические списания денег — тогда платёж выполняется без дополнительного подтверждения с вашей стороны.\nАвтосписания продолжатся даже при перевыпуске карты, если ваш банк умеет автоматически обновлять данные. Отменить их и отвязать карту можно в любой момент — через службу поддержки магазина.",
            comment: "Текст информации о работе автосписания https://disk.yandex.ru/i/r9l5HObi2jZy6A"
        )
        static let unbindInfoTitle = NSLocalizedString(
            "card.details.info.unbind.title",
            bundle: Bundle.framework,
            value: "Как отвязать карту от кошелька",
            comment: "Заголовок информации об отвязке карты https://disk.yandex.ru/i/59heYTl9Q4L2fA"
        )
        static let unbindInfoDetails = NSLocalizedString(
            "card.details.info.unbind.details",
            bundle: Bundle.framework,
            value: """
            Для этого зайдите в настройки кошелька на сайте или в приложении ЮMoney.
            В приложении: нажмите на свою аватарку, выберите «Банковские карты», смахните нужную карту влево и нажмите «Удалить».
            На сайте: перейдите в настройки кошелька, откройте вкладку «Привязанные карты», найдите нужную карту и нажмите «Отвязать».
            """,
            comment: "Текст информации об отвязке карты https://disk.yandex.ru/i/59heYTl9Q4L2fA"
        )
        static let unbindSuccess = NSLocalizedString(
            "card.details.unbind.success",
            bundle: Bundle.framework,
            value: "Карта %@ отвязана",
            comment: "Текст нотификации об успешной отвязке карты. Параметр - маска карты https://disk.yandex.ru/i/JWC70LuzuJSeEw"
        )
        static let unbindFail = NSLocalizedString(
            "card.details.unbind.fail",
            bundle: Bundle.framework,
            value: "Не удалось отвязать карту %@",
            comment: "Текст нотификации об ошибке отвязки карты. Параметр - маска карты https://disk.yandex.ru/i/QNJyBrfP52vQOw"
        )
    }

    enum RecurrencyAndSavePaymentData {
        static let saveDataInfoTitle = NSLocalizedString(
            "RecurrencyAndSavePaymentData.info.saveData.title",
            bundle: Bundle.framework,
            value: "Сохранение платёжных данных",
            comment: "Заголовок информации о сохранении данных карты https://disk.yandex.ru/i/yLD0tpyvO3zvLg"
        )
        static let saveDataInfoMessage = NSLocalizedString(
            "RecurrencyAndSavePaymentData.info.saveData.message",
            bundle: Bundle.framework,
            value: """
            Если вы это разрешили, мы сохраним для этого магазина и его партнёров данные вашей банковской карты — номер, имя владельца и срок действия (всё, кроме кода CVC). В следующий раз не нужно будет вводить их, чтобы заплатить в этом магазине.

            Удалить данные карты можно в процессе оплаты (нажмите на три точки напротив карты и выберите «Удалить карту») или через службу поддержки.
            """,
            comment: "Текст информации о сохранении данных карты https://disk.yandex.ru/i/yLD0tpyvO3zvLg"
        )
        static let saveDataAndAutopaymentsInfoTitle = NSLocalizedString(
            "RecurrencyAndSavePaymentData.info.saveDataAndAutopayments.title",
            bundle: Bundle.framework,
            value: "Автосписания и сохранение платёжных данных",
            comment: "Заголовок информации о сохранении данных карты и автосписаниях https://disk.yandex.ru/i/yLD0tpyvO3zvLg"
        )
        static let saveDataAndAutopaymentsInfoMessage = NSLocalizedString(
            "RecurrencyAndSavePaymentData.info.saveDataAndAutopayments.message",
            bundle: Bundle.framework,
            value: """
            Если вы это разрешили, мы сохраним для этого магазина и его партнёров данные вашей банковской карты — номер, имя владельца, срок действия (всё, кроме кода CVC). В следующий раз не нужно будет их вводить, чтобы заплатить в этом магазине.

            Кроме того, мы привяжем карту (в том числе использованную через Google Pay) к магазину. После этого магазин сможет присылать запросы на автоматические списания денег — тогда платёж выполняется без дополнительного подтверждения с вашей стороны.

            Автосписания продолжатся даже при перевыпуске карты, если ваш банк умеет автоматически обновлять данные. Отменить их и отвязать карту можно в любой момент — через службу поддержки магазина.
            """,
            comment: "Текст информации о сохранении данных карты и автосписаниях https://disk.yandex.ru/i/yLD0tpyvO3zvLg"
        )

        enum Header {
            static let requiredSaveDataAndAutopaymentsHeader = NSLocalizedString(
                "RecurrencyAndSavePaymentData.header.saveDataAndAutopayments.required",
                bundle: Bundle.framework,
                value: "Разрешим автосписания и сохраним платёжные данные",
                comment: "Текст информера о неопциональном подключении автосписания и сохранении данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
            )
            static let requiredAutopaymentsHeader = NSLocalizedString(
                "RecurrencyAndSavePaymentData.header.autopayments.required",
                bundle: Bundle.framework,
                value: "Разрешим автосписания",
                comment: "Текст информера о неопциональном подключении автосписания при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
            )
            static let requiredSaveDataHeader = NSLocalizedString(
                "RecurrencyAndSavePaymentData.header.saveData.required",
                bundle: Bundle.framework,
                value: "Сохраним платёжные данные",
                comment: "Текст информера о неопциональном сохранении платёжных данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
            )

            static let optionalSaveDataAndAutopaymentsHeader = NSLocalizedString(
                "RecurrencyAndSavePaymentData.header.saveDataAndAutopayments.optional",
                bundle: Bundle.framework,
                value: "Разрешить автосписания и сохранить платёжные данные",
                comment: "Текст информера о опциональном подключении автосписания и сохранении данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
            )
            static let optionalAutopaymentsHeader = NSLocalizedString(
                "RecurrencyAndSavePaymentData.header.autopayments.optional",
                bundle: Bundle.framework,
                value: "Разрешить автосписания",
                comment: "Текст информера о опциональном подключении автосписания при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
            )
            static let optionalSaveDataHeader = NSLocalizedString(
                "RecurrencyAndSavePaymentData.header.saveData.optional",
                bundle: Bundle.framework,
                value: "Сохранить платёжные данные",
                comment: "Текст информера о опциональном сохранении платёжных данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
            )
        }

        enum Link {
            enum Optional {
                static let saveDataLink = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.saveData.optional",
                    bundle: Bundle.framework,
                    value: "Магазин сохранит данные вашей карты — в следующий раз можно будет их не вводить",
                    comment: "Текст со ссылкой информации об опциональном сохранении платёжных данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let saveDataLinkInteractive = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.interactive.saveData.optional",
                    bundle: Bundle.framework,
                    value: "сохранит данные вашей карты",
                    comment: "Интерактивная часть текста со ссылкой информации об опциональном сохранении платёжных данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsLink = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.autopayments.optional",
                    bundle: Bundle.framework,
                    value: "После оплаты запомним эту карту: магазин сможет списывать деньги без вашего участия",
                    comment: "Текст со ссылкой информации об опциональном подключении автоплатежа при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsInteractive = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.interactive.autopayments.optional",
                    bundle: Bundle.framework,
                    value: "списывать деньги без вашего участия",
                    comment: "Интерактивная часть текста со ссылкой информации об опциональном подключении автоплатежа при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsAndSaveDataLink = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.autopaymentsAndSaveData.optional",
                    bundle: Bundle.framework,
                    value: "После оплаты магазин сохранит данные карты и сможет списывать деньги без вашего участия",
                    comment: "Текст со ссылкой информации об опциональном подключении автоплатежа и сохранения данных карты при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsAndSaveDataInteractive = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.interactive.autopaymentsAndSaveData.optional",
                    bundle: Bundle.framework,
                    value: "сохранит данные карты и сможет списывать деньги без вашего участия",
                    comment: "Интерактивная часть текста со ссылкой информации об опциональном подключении автоплатежа и сохранения данных карты при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
            }
            enum Required {
                static let saveDataLink = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.saveData.required",
                    bundle: Bundle.framework,
                    value: "Магазин сохранит данные вашей карты — в следующий раз можно будет их не вводить",
                    comment: "Текст со ссылкой информации об опциональном сохранении платёжных данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let saveDataLinkInteractive = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.interactive.saveData.required",
                    bundle: Bundle.framework,
                    value: "сохранит данные вашей карты",
                    comment: "Интерактивная часть текста со ссылкой информации об опциональном сохранении платёжных данных при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsLink = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.autopayments.required",
                    bundle: Bundle.framework,
                    value: "Заплатив здесь, вы разрешаете привязать карту и списывать деньги без вашего участия",
                    comment: "Текст со ссылкой информации об опциональном подключении автоплатежа при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsInteractive = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.interactive.autopayments.required",
                    bundle: Bundle.framework,
                    value: "списывать деньги без вашего участия",
                    comment: "Интерактивная часть текста со ссылкой информации об опциональном подключении автоплатежа при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsAndSaveDataLink = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.autopaymentsAndSaveData.required",
                    bundle: Bundle.framework,
                    value: "Заплатив здесь, вы соглашаетесь сохранить данные карты и списывать деньги без вашего участия",
                    comment: "Текст со ссылкой информации об опциональном подключении автоплатежа и сохранения данных карты при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
                static let autopaymentsAndSaveDataInteractive = NSLocalizedString(
                    "RecurrencyAndSavePaymentData.link.interactive.autopaymentsAndSaveData.required",
                    bundle: Bundle.framework,
                    value: "сохранить данные карты и списывать деньги без вашего участия",
                    comment: "Интерактивная часть текста со ссылкой информации об опциональном подключении автоплатежа и сохранения данных карты при платеже https://disk.yandex.ru/i/dcZY0utIfx634w"
                )
            }
        }
    }
    // swiftlint:enable line_length
}
