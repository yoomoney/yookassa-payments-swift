import UIKit

enum PriceViewStyle {
    case amount
    case fee
}

protocol PriceViewModel {
    var currency: String { get }
    var integerPart: String { get }
    var fractionalPart: String { get }
    var decimalSeparator: String { get }
    var style: PriceViewStyle { get }
}
