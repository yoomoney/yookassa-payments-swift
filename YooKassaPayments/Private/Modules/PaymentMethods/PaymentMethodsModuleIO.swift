import YooKassaPaymentsApi

struct PaymentMethodsModuleInputData {
    let clientApplicationKey: String
    let gatewayId: String?
    let amount: Amount
    let tokenizationSettings: TokenizationSettings
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool
    let getSavePaymentMethod: Bool?
    let moneyAuthClientId: String?
}

protocol PaymentMethodsModuleInput: class {
    func showPlaceholder(message: String)

    func reloadData()

    func yooMoneyAuthModule(
        _ module: YooMoneyAuthModuleInput,
        didSelectViewModel viewModel: PaymentMethodViewModel,
        at indexPath: IndexPath
    )
}

protocol PaymentMethodsModuleOutput: class {
    func paymentMethodsModule(
        _ module: PaymentMethodsModuleInput,
        didSelect paymentOption: PaymentOption,
        methodsCount: Int
    )
    func paymentMethodsModule(
        _ module: PaymentMethodsModuleInput,
        didPressLogout paymentOption: PaymentInstrumentYooMoneyWallet
    )
    func didFinish(on module: PaymentMethodsModuleInput)
}
