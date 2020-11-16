struct TempAmount: PriceViewModel {
    let currency: String
    let integerPart: String
    let fractionalPart: String
    let style: PriceViewStyle
    let decimalSeparator = Locale.current.decimalSeparator ?? ","
}
