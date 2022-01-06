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
    let termsOfService: NSAttributedString
    let merchantIdentifier: String?
    let savePaymentMethodViewModel: SavePaymentMethodViewModel?
    let initialSavePaymentMethod: Bool
    let isBackBarButtonHidden: Bool
    let customerId: String?
    let isSafeDeal: Bool
    let paymentOptionTitle: String?
}

protocol ApplePayContractModuleInput: AnyObject {}

protocol ApplePayContractModuleOutput: AnyObject {
    func tokenizationModule(
        _ module: ApplePayContractModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    )
}
