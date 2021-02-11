import YooKassaPaymentsApi

struct ApplePayContractModuleInputData {
    let clientApplicationKey: String
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool
    let tokenizationSettings: TokenizationSettings
    
    let shopName: String
    let purchaseDescription: String
    let price: PriceViewModel
    let fee: PriceViewModel?
    let paymentOption: PaymentOption
    let termsOfService: TermsOfService
    let merchantIdentifier: String?
    let savePaymentMethodViewModel: SavePaymentMethodViewModel?
    let initialSavePaymentMethod: Bool
}

protocol ApplePayContractModuleInput: class {}

protocol ApplePayContractModuleOutput: class {
    func tokenizationModule(
        _ module: ApplePayContractModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    )
}
