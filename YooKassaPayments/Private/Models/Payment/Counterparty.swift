import YooKassaPaymentsApi

/// Fee charged by the payee.
struct Counterparty {

    /// The amount in the selected currency.
    let charge: MonetaryAmount

    /// Creates instance of `Counterparty`.
    ///
    /// - Parameters:
    ///   - charge: The amount in the selected currency.
    ///
    /// - Returns: Instance of `Counterparty`.
    init(charge: MonetaryAmount) {
        self.charge = charge
    }
}

// MARK: - Counterparty converter

extension Counterparty {
    init(_ counterparty: YooKassaPaymentsApi.Counterparty) {
        self.init(
            charge: counterparty.charge.plain
        )
    }

    var paymentsModel: YooKassaPaymentsApi.Counterparty {
        return YooKassaPaymentsApi.Counterparty(self)
    }
}

extension YooKassaPaymentsApi.Counterparty {
    init(_ counterparty: Counterparty) {
        self.init(
            charge: counterparty.charge.paymentsModel
        )
    }

    var plain: Counterparty {
        return Counterparty(self)
    }
}
