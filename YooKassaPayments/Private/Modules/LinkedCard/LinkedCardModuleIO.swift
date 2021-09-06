import YooKassaPaymentsApi

struct LinkedCardModuleInputData {
    let clientApplicationKey: String
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool
    let moneyAuthClientId: String?
    let tokenizationSettings: TokenizationSettings

    let shopName: String
    let purchaseDescription: String
    let price: PriceViewModel
    let fee: PriceViewModel?
    let paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    let termsOfService: TermsOfService
    let returnUrl: String
    let tmxSessionId: String?
    let initialSavePaymentMethod: Bool
    let isBackBarButtonHidden: Bool
    let customerId: String?
    let isSafeDeal: Bool
}

protocol LinkedCardModuleInput: AnyObject {
    func hideActivity()
}

protocol LinkedCardModuleOutput: AnyObject {
    func tokenizationModule(
        _ module: LinkedCardModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    )
}
