import Foundation

struct PriceInputPresenterStyle: InputPresenterStyle {

    private let fractionPartLength = 2
    private let integerPartLength = 6

    func removedFormatting(from string: String) -> String {
        let components = string.components(separatedBy: PriceConstants.decimalSeparator)
        var integerPart: String = ""
        var fractionalPart: String = ""

        if !components.isEmpty {
            let integerString = components[0].components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            let trimmedIntegerString = integerString.prefix(integerPartLength)
            let integer = Int(trimmedIntegerString)
            integerPart = integer.flatMap(String.init) ?? ""
        }

        if components.count > 1 {
            let fraction = components[1].components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            let limitFraction = fraction.prefix(fractionPartLength)
            fractionalPart = PriceConstants.decimalSeparator + String(limitFraction)
        }

        return integerPart + fractionalPart
    }

    func appendedFormatting(to string: String) -> String {
        return PriceInputFormatter.inputLocalizedCurrency(string: string)
    }

    var maximalLength: Int {
        return Int.max
    }
}
