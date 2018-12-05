struct BankCardDataInputModuleInputData {
    let cardScanner: CardScanning?
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool
}

protocol BankCardDataInputModuleInput: class {
    func bankCardDidTokenize(_ error: Error)
}

protocol BankCardDataInputModuleOutput: class {
    func didPressCloseBarButtonItem(on module: BankCardDataInputModuleInput)
    func bankCardDataInputModule(_ module: BankCardDataInputModuleInput,
                                 didPressConfirmButton bankCardData: CardData)
}
