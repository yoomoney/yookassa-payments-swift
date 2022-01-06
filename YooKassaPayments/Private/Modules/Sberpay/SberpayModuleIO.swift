import YooKassaPaymentsApi

struct SberpayModuleInputData {
    let paymentOption: PaymentOption
    let clientSavePaymentMethod: SavePaymentMethod
    let clientApplicationKey: String
    let tokenizationSettings: TokenizationSettings
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool

    let shopName: String
    let purchaseDescription: String
    let priceViewModel: PriceViewModel
    let feeViewModel: PriceViewModel?
    let termsOfService: NSAttributedString
    let returnUrl: String
    let isBackBarButtonHidden: Bool
    let customerId: String?
    let isSafeDeal: Bool
    let config: Config
}

protocol SberpayModuleOutput: AnyObject {
    func sberpayModule(
        _ module: SberpayModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    )
}

protocol SberpayModuleInput: AnyObject {}
