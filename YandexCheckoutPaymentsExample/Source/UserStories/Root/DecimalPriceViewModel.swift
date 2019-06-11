import YandexCheckoutPayments

struct DecimalPriceViewModel: PriceViewModel {

    var currency: Character
    var integerPart: String
    var fractionalPart: String
    var decimalSeparator: String
    var style: PriceViewStyle = .amount

    // MARK: - Initialization/Deinitialization

    init(price: Decimal) {
        currency = PriceFormatter.currencySymbol.first ?? Character("")
        decimalSeparator = PriceFormatter.decimalSeparator
        let priceStringWithCurrency = PriceFormatter.localize(decimal: price) ?? ""
        let priceString = priceStringWithCurrency.replacingOccurrences(of: PriceFormatter.currencySymbol, with: "")
        if let decimalSeparatorCharacter = decimalSeparator.first,
           let separatorIndex = priceString.index(of: decimalSeparatorCharacter) {

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
