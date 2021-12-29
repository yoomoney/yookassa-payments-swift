import UIKit.UIImage

struct LinkedCardViewModel {
    let shopName: String
    let description: String?
    let price: PriceViewModel
    let fee: PriceViewModel?
    let cardMask: String
    let cardLogo: UIImage
    let terms: NSAttributedString
    let safeDealText: NSAttributedString?
}
