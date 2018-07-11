/// Currency
public enum Currency: String {

    /// The Russian ruble or rouble is the currency of the Russian Federation.
    case rub = "RUB"

    /// The United States dollar is the official currency of the United States.
    case usd = "USD"

    /// The euro is the official currency of the European Union.
    case eur = "EUR"

    /// Depending on the currency, returns a currency symbol.
    var symbol: Character {
        let result: Character
        switch self {
        case .rub:
            result = "₽"
        case .eur:
            result = "€"
        case .usd:
            result = "$"
        }
        return result
    }
}
