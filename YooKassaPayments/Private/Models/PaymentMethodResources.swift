import UIKit.UIImage

enum PaymentMethodResources {
    enum Localized {
        // swiftlint:disable line_length
        static let wallet = NSLocalizedString(
            "PaymentMethod.wallet",
            bundle: Bundle.framework,
            value: "ЮMoney",
            comment: "Способ оплаты - `ЮMoney` https://yadi.sk/i/smhhxBAxkP8Ebw"
        )
        static let applePay = NSLocalizedString(
            "PaymentMethod.applePay",
            bundle: Bundle.framework,
            value: "Apple Pay",
            comment: "Способ оплаты - `Apple Pay` https://yadi.sk/i/smhhxBAxkP8Ebw"
        )
        static let bankCard = NSLocalizedString(
            "PaymentMethod.bankCard",
            bundle: Bundle.framework,
            value: "Ввести новую карту",
            comment: "Способ оплаты - `Новая карта` https://disk.yandex.ru/d/wdNdER1Bis-YkA"
        )
        static let sberpay = NSLocalizedString(
            "PaymentMethod.sberpay",
            bundle: Bundle.framework,
            value: "SberPay",
            comment: "Способ оплаты - `SberPay` https://yadi.sk/i/smhhxBAxkP8Ebw"
        )
        static let yooMoneyCard = NSLocalizedString(
            "PaymentMethod.yooMoneyCard",
            bundle: Bundle.framework,
            value: "Карта Юмани",
            comment: "Способ оплаты - `Карта Юмани` https://disk.yandex.ru/d/sFpmR3gLEc287Q"
        )
        static let linkedCard = NSLocalizedString(
            "PaymentMethod.linkedCard",
            bundle: Bundle.framework,
            value: "Привязанная карта",
            comment: "Способ оплаты - `Привязанная карта` https://disk.yandex.ru/d/sFpmR3gLEc287Q"
        )
        static let safeDealInfoTitle = NSLocalizedString(
            "PaymentMethod.safeDealInfo.title",
            bundle: Bundle.framework,
            value: "Почему у платежа несколько получателей",
            comment: "Тайтл информации о безопасной сделке https://disk.yandex.ru/i/zOrGowAKK4uz3A"
        )
        static let safeDealInfoBody = NSLocalizedString(
            "PaymentMethod.safeDealInfo.body",
            bundle: Bundle.framework,
            value: "Такое может быть, если вы платите на интернет-площадке, которая позволяет покупать одновременно у нескольких продавцов (например, на маркетплейсе).\n\nУточнить список получателей платежа можно на площадке, на которой вы совершаете платёж.",
            comment: "Подробности о безопасной сделке https://disk.yandex.ru/i/zOrGowAKK4uz3A"
        )
        private static let safeDealInfoLinkPartHighlighted = NSLocalizedString(
            "PaymentMethod.safeDealInfo.link.highlighted",
            bundle: Bundle.framework,
            value: "несколько получателей",
            comment: "текст-ссылка интерактивная часть https://disk.yandex.ru/i/UOEMl4Ig3Z_4UA"
        )
        private static let safeDealInfoLinkPartBegining = NSLocalizedString(
            "PaymentMethod.safeDealInfo.link.begining",
            bundle: Bundle.framework,
            value: "У платежа может быть ",
            comment: "текст-ссылка https://disk.yandex.ru/i/UOEMl4Ig3Z_4UA"
        )

        static var safeDealInfoLink: NSAttributedString {
            let result = NSMutableAttributedString(
                attributedString: .init(
                    string: Self.safeDealInfoLinkPartBegining,
                    attributes: [.foregroundColor: UIColor.AdaptiveColors.secondary])
            )
            let link = NSAttributedString(
                string: Self.safeDealInfoLinkPartHighlighted,
                attributes: [.link: "yookassapayments://"]
            )
            result.append(link)
            result.addAttributes(
                [.font: UIFont.dynamicCaption2],
                range: NSRange(location: 0, length: (result.string as NSString).length)
            )
            return result
        }
        // swiftlint:enable line_length
    }

    enum Image {
        static let americanExpress = UIImage.named("PaymentMethod.AmericanExpress")
        static let applePay = UIImage.named("PaymentMethod.ApplePay")
        static let bankCard = UIImage.named("PaymentMethod.BankCard")
        static let cup = UIImage.named("PaymentMethod.Cup")
        static let dankort = UIImage.named("PaymentMethod.Dankort")
        static let dinersClub = UIImage.named("PaymentMethod.DinersClub")
        static let discoverCard = UIImage.named("PaymentMethod.DiscoverCard")
        static let instapay = UIImage.named("PaymentMethod.Instapay")
        static let jcb = UIImage.named("PaymentMethod.Jcb")
        static let lazer = UIImage.named("PaymentMethod.Lazer")
        static let maestro = UIImage.named("PaymentMethod.Maestro")
        static let mastercard = UIImage.named("PaymentMethod.Mastercard")
        static let mir = UIImage.named("PaymentMethod.Mir")
        static let solo = UIImage.named("PaymentMethod.Solo")
        static let `switch` = UIImage.named("PaymentMethod.Switch")
        static let unknown = UIImage.named("PaymentMethod.Unknown")
        static let visa = UIImage.named("PaymentMethod.Visa")
        static let yooMoney = UIImage.named("PaymentMethod.YooMoney")
        static let sberpay = UIImage.named("PaymentMethod.Sberpay")
        static let more = UIImage.named("icon2_name_more_s").colorizedImage(color: UIColor.AdaptiveColors.secondary)
        static let trash = UIImage.named("icon2_name_trash_m").colorizedImage(color: .white)
    }
}
