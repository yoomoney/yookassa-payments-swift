protocol BankCardDataInputRouterInput: class {
    func openCardScanner()
}

protocol BankCardDataInputRouterOutput: class {
    func cardScanningDidFinish(_ scannedCardInfo: ScannedCardInfo)
}
