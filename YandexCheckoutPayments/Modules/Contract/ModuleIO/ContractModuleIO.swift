struct ContractModuleInputData {
    let shopName: String
    let purchaseDescription: String
    let paymentMethod: PaymentMethodViewModel
    let price: PriceViewModel
    let shouldChangePaymentMethod: Bool
    let testModeSettings: TestModeSettings?
    let tokenizeScheme: AnalyticsEvent.TokenizeScheme
}

protocol ContractModuleInput: ContractStateHandler {}

protocol ContractModuleOutput: class {
    func didPressSubmitButton(on module: ContractModuleInput)
    func didPressChangeAction(on module: ContractModuleInput)
    func didPressLogoutButton(on module: ContractModuleInput)
    func didFinish(on module: ContractModuleInput)
}
