struct SberbankModuleInputData {
    let shopName: String
    let purchaseDescription: String
    let paymentMethod: PaymentMethodViewModel
    let price: PriceViewModel
    let fee: PriceViewModel?
    let shouldChangePaymentMethod: Bool
    let testModeSettings: TestModeSettings?
    let tokenizeScheme: AnalyticsEvent.TokenizeScheme
    let isLoggingEnabled: Bool
    let phoneNumber: String?
    let termsOfService: TermsOfService
    let savePaymentMethodViewModel: SavePaymentMethodViewModel?
}

protocol SberbankModuleInput: ContractStateHandler { }

protocol SberbankModuleOutput: class {
    func sberbank(_ module: SberbankModuleInput,
                  phoneNumber: String)
    func didFinish(on module: SberbankModuleInput)
    func didPressChangeAction(on module: SberbankModuleInput)

    func sberbank(_ module: SberbankModuleInput,
                  didTapTermsOfService url: URL)
}
