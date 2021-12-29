import YooKassaPaymentsApi

struct SberbankModuleInputData {
    let paymentOption: PaymentOption
    let clientApplicationKey: String
    let tokenizationSettings: TokenizationSettings
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool

    let shopName: String
    let purchaseDescription: String
    let priceViewModel: PriceViewModel
    let feeViewModel: PriceViewModel?
    let termsOfService: NSAttributedString
    let userPhoneNumber: String?
    let isBackBarButtonHidden: Bool
    let customerId: String?
    let isSafeDeal: Bool
    let clientSavePaymentMethod: SavePaymentMethod
    let config: Config
}

protocol SberbankModuleOutput: AnyObject {
    func sberbankModule(
        _ module: SberbankModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    )
}

protocol SberbankModuleInput: AnyObject {}
