/// Test mode settings.
public struct TestModeSettings {

    /// A Boolean value that determines whether payment authorization has been completed.
    public let paymentAuthorizationPassed: Bool

    /// Cards count.
    public let cardsCount: Int

    /// The amount to be paid.
    public let charge: Amount

    /// A Boolean value that determines whether the payment will end with an error.
    public let enablePaymentError: Bool

    /// Creates instance of `TestModeSettings`.
    ///
    /// - Parameters:
    ///   - paymentAuthorizationPassed: A Boolean value that determines whether
    ///                                 payment authorization has been completed.
    ///   - cardsCount: Cards count.
    ///   - charge: The amount to be paid.
    ///   - enablePaymentError: A Boolean value that determines whether the payment will end with an error.
    ///
    /// - Returns: Instance of `TestModeSettings`.
    public init(paymentAuthorizationPassed: Bool,
                cardsCount: Int,
                charge: Amount,
                enablePaymentError: Bool) {
        self.paymentAuthorizationPassed = paymentAuthorizationPassed
        self.cardsCount = cardsCount
        self.charge = charge
        self.enablePaymentError = enablePaymentError
    }
}
