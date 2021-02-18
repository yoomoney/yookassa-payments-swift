import YooKassaPaymentsApi

struct YooMoneyModuleInputData {
    let clientApplicationKey: String
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool
    let moneyAuthClientId: String?
    let tokenizationSettings: TokenizationSettings
    
    let shopName: String
    let purchaseDescription: String
    let price: PriceViewModel
    let fee: PriceViewModel?
    let paymentMethod: PaymentMethodViewModel
    let paymentOption: PaymentInstrumentYooMoneyWallet
    let termsOfService: TermsOfService
    let returnUrl: String
    let savePaymentMethodViewModel: SavePaymentMethodViewModel?
    let tmxSessionId: String?
    let initialSavePaymentMethod: Bool
}

protocol YooMoneyModuleInput: class {}

protocol YooMoneyModuleOutput: class {
    func didLogout(
        _ module: YooMoneyModuleInput
    )
    
    func tokenizationModule(
        _ module: YooMoneyModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    )
}

