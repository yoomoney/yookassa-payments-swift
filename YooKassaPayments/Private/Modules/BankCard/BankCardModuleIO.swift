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
    let termsOfService: TermsOfService
    let cardScanning: CardScanning?
    let returnUrl: String
    let savePaymentMethodViewModel: SavePaymentMethodViewModel?
    let initialSavePaymentMethod: Bool
}

protocol BankCardModuleOutput: class {
    func bankCardModule(
        _ module: BankCardModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    )
}

protocol BankCardModuleInput: class {}
