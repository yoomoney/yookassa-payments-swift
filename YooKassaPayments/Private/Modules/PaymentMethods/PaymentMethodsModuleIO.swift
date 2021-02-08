import YooKassaPaymentsApi

struct PaymentMethodsModuleInputData {
    let clientApplicationKey: String
    let gatewayId: String?
    let shopName: String
    let purchaseDescription: String
    let amount: Amount
    let tokenizationSettings: TokenizationSettings
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool
    let getSavePaymentMethod: Bool?
    let moneyAuthClientId: String?
    let returnUrl: String?
    let savePaymentMethod: SavePaymentMethod
}

protocol PaymentMethodsModuleInput: class {}

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
    func tokenizationModule(
        _ module: PaymentMethodsModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    )
}
