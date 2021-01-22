import YooKassaPaymentsApi

/// Commission from the buyer in excess of the payment amount.
/// The field is present if there are commissions in excess of the payment amount.
struct Fee {

    /// Commission charged by YooKassa.
    let service: Service?

    /// Fee charged by the payee.
    let counterparty: Counterparty?

    /// Creates instance of `Fee`.
    ///
    /// - Parameters:
    ///   - service: Commission charged by YooKassa.
    ///   - counterparty: Fee charged by the payee.
    ///
    /// - Returns: Instance of `Fee`.
    init(
        service: Service?,
        counterparty: Counterparty?
    ) {
        self.service = service
        self.counterparty = counterparty
    }
}

// MARK: - Fee converter

extension Fee {
    init(_ fee: YooKassaPaymentsApi.Fee) {
        self.init(
            service: fee.service?.plain,
            counterparty: fee.counterparty?.plain
        )
    }

    var paymentsModel: YooKassaPaymentsApi.Fee {
        return YooKassaPaymentsApi.Fee(self)
    }
}

extension YooKassaPaymentsApi.Fee {
    init(_ fee: Fee) {
        self.init(
            service: fee.service?.paymentsModel,
            counterparty: fee.counterparty?.paymentsModel
        )
    }

    var plain: Fee {
        return Fee(self)
    }
}
