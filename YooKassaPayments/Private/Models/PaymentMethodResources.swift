import UIKit.UIImage

enum PaymentMethodResources {
    enum Localized {
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
            value: "Банковская карта",
            comment: "Способ оплаты - `Банковская карта` https://yadi.sk/i/smhhxBAxkP8Ebw"
        )
        static let sberpay = NSLocalizedString(
            "PaymentMethod.sberpay",
            bundle: Bundle.framework,
            value: "SberPay",
            comment: "Способ оплаты - `SberPay` https://yadi.sk/i/smhhxBAxkP8Ebw"
        )
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
    }
}
