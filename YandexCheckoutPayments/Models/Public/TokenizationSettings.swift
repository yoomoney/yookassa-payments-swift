/// Tokenization settings.
public struct TokenizationSettings {

    /// Type of the source of funds for the payment.
    public let paymentMethodTypes: PaymentMethodTypes

    /// A Boolean value that determines whether Yandex checkout
    /// logo will be displayed on the screen of available payment methods.
    public let showYandexCheckoutLogo: Bool

    /// Creates instance of `TokenizationSettings`.
    ///
    /// - Parameters:
    ///   - paymentMethodTypes: Type of the source of funds for the payment.
    ///   - showYandexCheckoutLogo: A Boolean value that determines whether Yandex checkout
    ///                             logo will be displayed on the screen of available payment methods.
    ///
    /// - Returns: Instance of `TokenizationSettings`
    public init(paymentMethodTypes: PaymentMethodTypes = .all,
                showYandexCheckoutLogo: Bool = true) {
        self.paymentMethodTypes = paymentMethodTypes
        self.showYandexCheckoutLogo = showYandexCheckoutLogo
    }
}
