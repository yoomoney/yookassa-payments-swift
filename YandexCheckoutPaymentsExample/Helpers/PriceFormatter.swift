import Foundation

enum PriceFormatter {

    static var currencySymbol: String {
        return "₽"
    }

    private static var balanceNumberFormatter: NumberFormatter = {
        $0.currencySymbol = currencySymbol
        $0.numberStyle = .currency
        return $0
    }(NumberFormatter())

    static func localize(decimal: Decimal) -> String? {
        return balanceNumberFormatter.string(for: decimal)
    }
}
