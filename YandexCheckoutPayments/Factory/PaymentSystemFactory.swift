import class UIKit.UIImage

enum PaymentSystemFactory {

    static func makePaymentSystemImageFromCardType(_ cardType: CardType?) -> UIImage {
        let image: UIImage

        switch cardType {
        case .none:
            image = UIImage.PaymentSystem.TextControl.bankCard
        case .visa?:
            image = UIImage.PaymentSystem.TextControl.visa
        case .masterCard?:
            image = UIImage.PaymentSystem.TextControl.masterCard
        case .maestro?:
            image = UIImage.PaymentSystem.TextControl.maestro
        case .mir?:
            image = UIImage.PaymentSystem.TextControl.mir
        }
        return image
    }
}
