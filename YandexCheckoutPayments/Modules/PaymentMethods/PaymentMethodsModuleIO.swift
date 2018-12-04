import YandexCheckoutPaymentsApi

struct PaymentMethodsModuleInputData {
    let clientApplicationKey: String
    let gatewayId: String?
    let amount: Amount
    let tokenizationSettings: TokenizationSettings
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool
}

protocol PaymentMethodsModuleInput: class {
    func showPlaceholder(message: String)
}

protocol PaymentMethodsModuleOutput: class {
    func paymentMethodsModule(_ module: PaymentMethodsModuleInput,
                              didSelect paymentOption: PaymentOption,
                              methodsCount: Int)
    func paymentMethodsModule(_ module: PaymentMethodsModuleInput,
                              didPressLogout paymentOption: PaymentInstrumentYandexMoneyWallet)
    func didFinish(on module: PaymentMethodsModuleInput)
}
