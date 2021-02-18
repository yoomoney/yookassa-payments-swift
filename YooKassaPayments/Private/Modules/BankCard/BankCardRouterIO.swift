protocol BankCardRouterInput: class {
    func presentTermsOfServiceModule(
        _ url: URL
    )
    func presentSavePaymentMethodInfo(
        inputData: SavePaymentMethodInfoModuleInputData
    )
    func openCardScanner()
}

protocol BankCardRouterOutput: class {
    func cardScanningDidFinish(
        _ scannedCardInfo: ScannedCardInfo
    )
}

