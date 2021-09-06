import UIKit

struct BankCardViewModel {
    let shopName: String
    let description: String?
    let priceValue: String
    let feeValue: String?
    let termsOfService: NSAttributedString
    let instrumentMode: Bool
    let maskedNumber: String
    let cardLogo: UIImage
    let safeDealText: NSAttributedString?
    let recurrencyAndDataSavingSection: UIView?
}
