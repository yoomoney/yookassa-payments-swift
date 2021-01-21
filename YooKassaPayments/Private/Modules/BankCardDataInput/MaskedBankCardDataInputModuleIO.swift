struct MaskedBankCardDataInputModuleInputData {
    let cardMask: String
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool
    let analyticsEvent: AnalyticsEvent?
    let tokenizeScheme: AnalyticsEvent.TokenizeScheme?
}

protocol MaskedBankCardDataInputModuleOutput: class {
    func didPressCloseBarButtonItem(on module: BankCardDataInputModuleInput)
    func didPressConfirmButton(
        on module: BankCardDataInputModuleInput,
        cvc: String
    )
}
