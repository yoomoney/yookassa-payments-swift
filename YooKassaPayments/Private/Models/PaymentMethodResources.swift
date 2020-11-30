import UIKit.UIImage

enum PaymentMethodResources {
    enum Localized: String {
        case wallet = "PaymentMethod.wallet"
        case applePay = "PaymentMethod.applePay"
        case bankCard = "PaymentMethod.bankCard"
        case sberbank = "PaymentMethod.sberbank"
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
        static let sberbank = UIImage.named("PaymentMethod.Sberbank")
    }
}
