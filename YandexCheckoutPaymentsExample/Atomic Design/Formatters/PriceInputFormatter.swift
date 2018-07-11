import UIKit

enum PriceInputFormatter {

    private static var priceNumberFormatter: NumberFormatter = {
        $0.currencySymbol = PriceConstants.currencySymbol
        $0.numberStyle = .currency
        return $0
    }(NumberFormatter())

    static func format(string: String) -> NSAttributedString {

        let attributedText = NSMutableAttributedString()

        let sumAttributes: [NSAttributedStringKey: Any]
        let currencyAttributes: [NSAttributedStringKey: Any]

        if #available(iOS 9.0, *) {
            sumAttributes = [
                NSAttributedStringKey.font: UIFont.dynamicTitle2,
            ]
            currencyAttributes = [
                NSAttributedStringKey.font: UIFont.dynamicTitle2Light,
            ]
        } else {
            sumAttributes = [
                NSAttributedStringKey.font: UIFont.dynamicHeadline1,
            ]
            currencyAttributes = sumAttributes
        }

        attributedText.append(NSAttributedString(string: string,
                                                 attributes: sumAttributes))

        if let currencyRange = string.range(of: PriceConstants.currencySymbol) {
            attributedText.addAttributes(currencyAttributes, range: NSRange(currencyRange, in: string))
        }

        return attributedText
    }

    static func fullLocalizedCurrency(string: String) -> String {
        guard let decimal = Decimal(string: string, locale: Locale.current) else {
            return ""
        }

        return priceNumberFormatter.string(for: decimal) ?? ""
    }

    static func fullLocalizedCurrency(decimal: Decimal) -> String {
        var decimalCopy = decimal
        return fullLocalizedCurrency(string: NSDecimalString(&decimalCopy, Locale.current))
    }

    static func inputLocalizedCurrency(string: String) -> String {
        guard let decimal = Decimal(string: string, locale: Locale.current),
              let fullNumber = priceNumberFormatter.string(for: decimal),
              let firstCharacter = fullNumber.first,
              string.isEmpty == false else {

            return ""
        }
        let firstSymbol = String(firstCharacter)

        var result = string
        if result.hasPrefix(PriceConstants.decimalSeparator) {
            result.insert("0", at: result.startIndex)
        }
        if firstSymbol == PriceConstants.currencySymbol {
            return "\(PriceConstants.currencySymbol)" + result
        } else {
            return result + " \(PriceConstants.currencySymbol)"
        }
    }
}
