import YooKassaPaymentsApi

/// Commission charged by YooKassa.
struct Service {

    /// The amount in the selected currency.
    let charge: MonetaryAmount

    /// Creates instance of `Service`.
    ///
    /// - Parameters:
    ///   - charge: The amount in the selected currency.
    ///
    /// - Returns: Instance of `Service`.
    init(charge: MonetaryAmount) {
        self.charge = charge
    }
}

// MARK: - Service converter

extension Service {
    init(_ service: YooKassaPaymentsApi.Service) {
        self.init(
            charge: service.charge.plain
        )
    }

    var paymentsModel: YooKassaPaymentsApi.Service {
        return YooKassaPaymentsApi.Service(self)
    }
}

extension YooKassaPaymentsApi.Service {
    init(_ service: Service) {
        self.init(
            charge: service.charge.paymentsModel
        )
    }

    var plain: Service {
        return Service(self)
    }
}
