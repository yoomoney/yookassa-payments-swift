import YooKassaPaymentsApi

struct BankCardModuleInputData {
    let clientApplicationKey: String
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool
    let tokenizationSettings: TokenizationSettings
    let shopName: String
    let purchaseDescription: String
    let priceViewModel: PriceViewModel
    let feeViewModel: PriceViewModel?
    let paymentOption: PaymentOption
    let termsOfService: NSAttributedString
    let cardScanning: CardScanning?
    let returnUrl: String
    let savePaymentMethod: SavePaymentMethod
    let canSaveInstrument: Bool
    let apiSavePaymentMethod: YooKassaPaymentsApi.SavePaymentMethod
    let isBackBarButtonHidden: Bool
    let customerId: String?
    let instrument: PaymentInstrumentBankCard?
    let isSafeDeal: Bool
    let config: Config
}

protocol BankCardModuleOutput: AnyObject {
    func bankCardModule(
        _ module: BankCardModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    )
}

protocol BankCardModuleInput: AnyObject {
    func hideActivity()
}
