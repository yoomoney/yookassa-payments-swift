/// Currency
public enum Currency {

    /// The Russian ruble or rouble is the currency of the Russian Federation.
    case rub

    /// The United States dollar is the official currency of the United States.
    case usd

    /// The euro is the official currency of the European Union.
    case eur

    /// Code in ISO-4217 format.
    case custom(String)
}

extension Currency {
    /// Depending on the currency, returns a currency symbol.
    var symbol: String {
        let result: String
        switch self {
        case .rub:
            result = "₽"
        case .eur:
            result = "€"
        case .usd:
            result = "$"
        case .custom(let value):
            return value
        }
        return result
    }
}

extension Currency: RawRepresentable {
    public typealias RawValue = String

    public init?(rawValue: String) {
        switch rawValue {
        case "RUB":
            self = .rub
        case "USD":
            self = .usd
        case "EUR":
            self = .eur
        default:
            self = .custom(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .rub:
            return "RUB"
        case .usd:
            return "USD"
        case .eur:
            return "EUR"
        case .custom(let value):
            return value
        }
    }
}
