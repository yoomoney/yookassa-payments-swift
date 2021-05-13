import YooKassaPaymentsApi

enum PriceViewModelFactoryAssembly {
    static func makeFactory() -> PriceViewModelFactory {
        PriceViewModelFactoryImpl()
    }
}

protocol PriceViewModelFactory {
    func makeAmountPriceViewModel(
        _ paymentOption: PaymentOption
    ) -> PriceViewModel

    func makeFeePriceViewModel(
        _ paymentOption: PaymentOption
    ) -> PriceViewModel?
}

final class PriceViewModelFactoryImpl {}

// MARK: - PriceViewModelFactory

extension PriceViewModelFactoryImpl: PriceViewModelFactory {
    func makeAmountPriceViewModel(
        _ paymentOption: PaymentOption
    ) -> PriceViewModel {
        let amountString = paymentOption.charge.value.description
        var integerPart = ""
        var fractionalPart = ""

        if let separatorIndex = amountString.firstIndex(of: ".") {
            integerPart = String(amountString[amountString.startIndex..<separatorIndex])
            fractionalPart = String(amountString[amountString.index(after: separatorIndex)..<amountString.endIndex])
        } else {
            integerPart = amountString
            fractionalPart = "00"
        }
        let currency = Currency(rawValue: paymentOption.charge.currency)
            ?? Currency.custom(paymentOption.charge.currency)
        return TempAmount(
            currency: currency.symbol,
            integerPart: integerPart,
            fractionalPart: fractionalPart,
            style: .amount
        )
    }

    func makeFeePriceViewModel(
        _ paymentOption: PaymentOption
    ) -> PriceViewModel? {
        guard let fee = paymentOption.fee,
              let service = fee.service else { return nil }

        let amountString = service.charge.value.description
        var integerPart = ""
        var fractionalPart = ""

        if let separatorIndex = amountString.firstIndex(of: ".") {
            integerPart = String(amountString[amountString.startIndex..<separatorIndex])
            fractionalPart = String(amountString[amountString.index(after: separatorIndex)..<amountString.endIndex])
        } else {
            integerPart = amountString
            fractionalPart = "00"
        }
        let currency = Currency(rawValue: service.charge.currency)
            ?? Currency.custom(service.charge.currency)
        return TempAmount(
            currency: currency.symbol,
            integerPart: integerPart,
            fractionalPart: fractionalPart,
            style: .fee
        )
    }
}
