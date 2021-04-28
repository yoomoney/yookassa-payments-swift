import Foundation

protocol AmountNumberFormatter {
    func string(from: Decimal) -> String
}

enum AmountNumberFormatterAssembly {
    static func makeAmountNumberFormatter() -> AmountNumberFormatter {
        return AmountNumberFormatterImpl()
    }
}

final class AmountNumberFormatterImpl {
    private lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter
    }()
}

extension AmountNumberFormatterImpl: AmountNumberFormatter {
    func string(from value: Decimal) -> String {
        let decimalNumber = NSDecimalNumber(decimal: value)
        let resultValue = numberFormatter.string(from: decimalNumber)
        return resultValue ?? value.description
    }
}
