import Foundation

struct ContractModuleInputData {
    let shopName: String
    let purchaseDescription: String
    let paymentMethod: PaymentMethodViewModel
    let price: PriceViewModel
    let fee: PriceViewModel?
    let shouldChangePaymentMethod: Bool
    let testModeSettings: TestModeSettings?
    let tokenizeScheme: AnalyticsEvent.TokenizeScheme
    let isLoggingEnabled: Bool
    let termsOfService: TermsOfService
    let recurringViewModel: RecurringViewModel?
}

protocol ContractModuleInput: ContractStateHandler {}

protocol ContractModuleOutput: class {
    func didPressSubmitButton(
        on module: ContractModuleInput
    )
    func didPressChangeAction(
        on module: ContractModuleInput
    )
    func didPressLogoutButton(
        on module: ContractModuleInput
    )
    func didFinish(
        on module: ContractModuleInput
    )
    func contractModule(
        _ module: ContractModuleInput,
        didTapTermsOfService url: URL
    )
    func contractModule(
        _ module: ContractModuleInput,
        didChangeRecurringState state: Bool
    )
    func didTapOnRecurringInfo(
        on module: ContractModuleInput
    )
}
