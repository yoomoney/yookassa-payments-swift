import YooKassaPaymentsApi

enum BankCardRegexType {
    case americanExpress
    case masterCard
    case visa
    case mir
    case maestro
}

struct BankCardRegex {
    let type: BankCardRegexType
    let regex: String
}
