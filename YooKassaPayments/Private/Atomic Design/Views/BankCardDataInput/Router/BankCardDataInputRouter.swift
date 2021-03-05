final class BankCardDataInputRouter {

    // MARK: - VIPER

    weak var transitionHandler: TransitionHandler?
    weak var output: BankCardDataInputRouterOutput?

    // MARK: - Initialization

    private let cardScanner: CardScanning?

    init(
        cardScanner: CardScanning?
    ) {
        self.cardScanner = cardScanner
    }
}

// MARK: - BankCardDataInputRouterInput

extension BankCardDataInputRouter: BankCardDataInputRouterInput {
    func openCardScanner() {
        guard let cardScanner = cardScanner,
              let viewController = cardScanner.cardScanningViewController,
              let transitionHandler = transitionHandler else { return }
        cardScanner.cardScanningDelegate = self
        transitionHandler.present(viewController, animated: true, completion: nil)
    }

}

// MARK: - CardScanningDelegate

extension BankCardDataInputRouter: CardScanningDelegate {
    func cardScannerDidFinish(
        _ cardInfo: ScannedCardInfo?
    ) {
        transitionHandler?.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.cardScanner?.cardScanningDelegate = nil
            if let cardInfo = cardInfo {
                self.output?.cardScanningDidFinish(cardInfo)
            }
        }
    }
}
