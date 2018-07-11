struct BankCardDataInputModuleInputData {
    let cardScanner: CardScanning?
    let testModeSettings: TestModeSettings?
}

protocol BankCardDataInputModuleInput: class {
    func bankCardDidTokenize(_ error: Error)
}

protocol BankCardDataInputModuleOutput: class {
    func didPressCloseBarButtonItem(on module: BankCardDataInputModuleInput)
    func bankCardDataInputModule(_ module: BankCardDataInputModuleInput,
                                 didPressConfirmButton bankCardData: CardData)
}
