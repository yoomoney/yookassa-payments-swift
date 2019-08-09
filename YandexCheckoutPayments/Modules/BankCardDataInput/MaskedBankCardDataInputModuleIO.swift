struct MaskedBankCardDataInputModuleInputData {
    let cardMask: String
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool
    let analyticsEvent: AnalyticsEvent?
}

protocol MaskedBankCardDataInputModuleOutput: class {
    func didPressCloseBarButtonItem(on module: BankCardDataInputModuleInput)
    func didPressConfirmButton(on module: BankCardDataInputModuleInput,
                               cvc: String)
}
