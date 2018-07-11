struct TempAmount: PriceViewModel {
    private(set) var currency: Character
    private(set) var integerPart: String = ""
    private(set) var fractionalPart: String = ""
    let decimalSeparator = Locale.current.decimalSeparator ?? ","

    static let tempPrice = TempAmount(currency: Character("₽"),
                                      integerPart: "29675",
                                      fractionalPart: "50")
}
