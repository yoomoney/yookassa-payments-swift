import Foundation

/// Amount of payment.
public struct Amount {

    /// Amount of payment.
    public let value: Decimal

    /// Currency.
    public let currency: Currency

    /// Creates instance of `Amount`.
    ///
    /// - Parameters:
    ///   - value: Amount of payment.
    ///   - currency: Currency.
    ///
    /// - Returns: Amount of payment.
    public init(value: Decimal, currency: Currency) {
        self.value = value
        self.currency = currency
    }
}
