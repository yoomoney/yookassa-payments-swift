import YooKassaPaymentsApi

/// Request information about your saved payment method.
/// The request allows you to get information about the saved payment method by its unique identifier.
/// In response to the request, the data of the saved payment method will come.
struct PaymentMethod {

    /// Payment method code.
    let type: PaymentMethodType

    /// The ID of the payment method.
    let id: String

    /// You can use your saved payment method to make direct debits.
    let saved: Bool

    /// The name of the payment method.
    let title: String?

    /// To pay by credit card you need to enter CVV2/CVC2/CVP2 code.
    let cscRequired: Bool

    /// Your credit card details.
    let card: PaymentMethodBankCard?

    /// Creates instance of `PaymentMethod`.
    ///
    /// - Parameters:
    ///   - type: Payment method code.
    ///   - id: The ID of the payment method.
    ///   - saved: You can use your saved payment method to make direct debits.
    ///   - title: The name of the payment method.
    ///   - cscRequired: To pay by credit card you need to enter CVV2/CVC2/CVP2 code.
    ///   - card: Your credit card details.
    ///
    /// - Returns: Instance of `PaymentMethod`.
    init(
        type: PaymentMethodType,
        id: String,
        saved: Bool,
        title: String?,
        cscRequired: Bool,
        card: PaymentMethodBankCard?
    ) {
        self.type = type
        self.id = id
        self.saved = saved
        self.title = title
        self.cscRequired = cscRequired
        self.card = card
    }
}

// MARK: - PaymentMethod converter

extension PaymentMethod {
    init(_ paymentMethod: YooKassaPaymentsApi.PaymentMethod) {
        self.init(
            type: paymentMethod.type.plain,
            id: paymentMethod.id,
            saved: paymentMethod.saved,
            title: paymentMethod.title,
            cscRequired: paymentMethod.cscRequired,
            card: paymentMethod.card?.plain
        )
    }

    var paymentsModel: YooKassaPaymentsApi.PaymentMethod {
        return YooKassaPaymentsApi.PaymentMethod(self)
    }
}

extension YooKassaPaymentsApi.PaymentMethod {
    init(_ paymentMethod: PaymentMethod) {
        self.init(
            type: paymentMethod.type.paymentsModel,
            id: paymentMethod.id,
            saved: paymentMethod.saved,
            title: paymentMethod.title,
            cscRequired: paymentMethod.cscRequired,
            card: paymentMethod.card?.paymentsModel
        )
    }

    var plain: PaymentMethod {
        return PaymentMethod(self)
    }
}
