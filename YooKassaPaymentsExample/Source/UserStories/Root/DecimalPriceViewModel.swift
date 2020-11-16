import YooKassaPayments

struct DecimalPriceViewModel: PriceViewModel {

    var currency: String
    var integerPart: String
    var fractionalPart: String
    var decimalSeparator: String
    var style: PriceViewStyle = .amount

    // MARK: - Initialization/Deinitialization

    init(price: Decimal) {
        currency = PriceFormatter.currencySymbol
        decimalSeparator = PriceFormatter.decimalSeparator
        let priceStringWithCurrency = PriceFormatter.localize(decimal: price) ?? ""
        let priceString = priceStringWithCurrency.replacingOccurrences(of: PriceFormatter.currencySymbol, with: "")
        if let decimalSeparatorCharacter = decimalSeparator.first,
           let separatorIndex = priceString.firstIndex(of: decimalSeparatorCharacter) {

            let fractionalPartStartIndex = priceString.index(after: separatorIndex)
            let fractionalPartEndIndex = priceString.index(after: fractionalPartStartIndex)

            integerPart = String(priceString[..<separatorIndex])
            fractionalPart = String(priceString[fractionalPartStartIndex...fractionalPartEndIndex])
        } else {
            integerPart = priceString
            fractionalPart = ""
        }
    }
}
