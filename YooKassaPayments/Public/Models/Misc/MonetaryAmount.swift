import YooKassaPaymentsApi
import YooKassaWalletApi

public struct MonetaryAmount: Equatable {

    public let value: Decimal
    public let currency: String

    public init(
        value: Decimal,
        currency: String
    ) {
        self.value = value
        self.currency = currency
    }
}

// MARK: - MonetaryAmount converter

extension MonetaryAmount {
    init(_ monetaryAmount: YooKassaWalletApi.MonetaryAmount) {
        self.init(
            value: monetaryAmount.value,
            currency: monetaryAmount.currency
        )
    }

    init(_ monetaryAmount: YooKassaPaymentsApi.MonetaryAmount) {
        self.init(
            value: monetaryAmount.value,
            currency: monetaryAmount.currency
        )
    }

    var walletModel: YooKassaWalletApi.MonetaryAmount {
        return YooKassaWalletApi.MonetaryAmount(self)
    }

    var paymentsModel: YooKassaPaymentsApi.MonetaryAmount {
        return YooKassaPaymentsApi.MonetaryAmount(self)
    }
}

extension YooKassaWalletApi.MonetaryAmount {
    init(_ monetaryAmount: MonetaryAmount) {
        self.init(
            value: monetaryAmount.value,
            currency: monetaryAmount.currency
        )
    }

    var plain: MonetaryAmount {
        return MonetaryAmount(self)
    }
}

extension YooKassaPaymentsApi.MonetaryAmount {
    init(_ monetaryAmount: MonetaryAmount) {
        self.init(
            value: monetaryAmount.value,
            currency: monetaryAmount.currency
        )
    }

    var plain: MonetaryAmount {
        return MonetaryAmount(self)
    }
}
