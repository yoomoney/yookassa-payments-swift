import YooKassaPaymentsApi

/// Payment confirmation method.
struct Confirmation {

    /// Type of custom payment confirmation process.
    /// Read more about the scenarios of [confirmation of payment](https://yookassa.ru/docs/guides/#confirmation)
    /// by the buyer.
    let type: ConfirmationType

    /// Address of the page to which the user will return.
    let returnUrl: String?

    /// Creates instance of Confirmation.
    ///
    /// - Parameters:
    ///   - type: Type of custom payment confirmation process.
    ///           Read more about the scenarios of [confirmation of payment](https://yookassa.ru/docs/guides/#confirmation)
    ///           by the buyer.
    ///   - returnUrl: Address of the page to which the user will return.
    init(
        type: ConfirmationType,
        returnUrl: String?
    ) {
        self.type = type
        self.returnUrl = returnUrl
    }
}

// MARK: - BankCard converter

extension Confirmation {
    init(_ confirmation: YooKassaPaymentsApi.Confirmation) {
        self.init(
            type: confirmation.type.plain,
            returnUrl: confirmation.returnUrl
        )
    }

    var paymentsModel: YooKassaPaymentsApi.Confirmation {
        return YooKassaPaymentsApi.Confirmation(self)
    }
}

extension YooKassaPaymentsApi.Confirmation {
    init(_ confirmation: Confirmation) {
        self.init(
            type: confirmation.type.paymentsModel,
            returnUrl: confirmation.returnUrl
        )
    }

    var plain: Confirmation {
        return Confirmation(self)
    }
}
