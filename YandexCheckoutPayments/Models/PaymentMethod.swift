import UIKit.UIImage
import struct YandexCheckoutPaymentsApi.MonetaryAmount

struct PaymentMethod: PaymentMethodViewModel {
    let name: String
    let image: UIImage
    let balance: MonetaryAmount?
}
