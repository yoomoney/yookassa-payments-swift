struct ApplePayContractModuleInputData {
    let shopName: String
    let purchaseDescription: String
    let paymentMethod: PaymentMethodViewModel
    let price: PriceViewModel
    let fee: PriceViewModel?
    let shouldChangePaymentMethod: Bool
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool
    let termsOfService: TermsOfService
    let recurringViewModel: RecurringViewModel?
}

protocol ApplePayContractModuleInput: class {}

protocol ApplePayContractModuleOutput: class {
    func didFinish(on module: ApplePayContractModuleInput)
    func didPressChangeAction(on module: ApplePayContractModuleInput)
    func didPressSubmitButton(on module: ApplePayContractModuleInput)
    func applePayContractModule(_ module: ApplePayContractModuleInput,
                                didTapTermsOfService url: URL)
}
