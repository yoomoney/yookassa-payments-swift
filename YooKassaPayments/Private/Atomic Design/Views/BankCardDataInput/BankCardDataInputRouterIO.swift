protocol BankCardDataInputRouterInput: AnyObject {
    func openCardScanner()
}

protocol BankCardDataInputRouterOutput: AnyObject {
    func cardScanningDidFinish(
        _ scannedCardInfo: ScannedCardInfo
    )
}
