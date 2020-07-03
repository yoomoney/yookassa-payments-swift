import UIKit.UIImage

struct PaymentMethod: PaymentMethodViewModel {
    let name: String
    let image: UIImage
    let balance: Amount?
}
