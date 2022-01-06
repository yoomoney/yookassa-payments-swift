enum PaymentMethodViewModelFactoryAssembly {
    static func makeFactory(isLoggingEnabled: Bool) -> PaymentMethodViewModelFactory {
        return PaymentMethodViewModelFactoryImpl(
            bankSettingsService: BankServiceSettingsImpl.shared,
            configMediator: ConfigMediatorImpl(
                service: ConfigServiceAssembly.make(isLoggingEnabled: isLoggingEnabled),
                storage: KeyValueStoringAssembly.makeSettingsStorage()
            )
        )
    }
}
