enum PaymentMethodViewModelFactoryAssembly {
    static func makeFactory() -> PaymentMethodViewModelFactory {
        return PaymentMethodViewModelFactoryImpl(
            bankSettingsService: BankServiceSettingsImpl.shared
        )
    }
}
