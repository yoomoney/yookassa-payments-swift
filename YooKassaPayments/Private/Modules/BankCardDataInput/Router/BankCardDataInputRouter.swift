import UIKit.UIViewController

final class BankCardDataInputRouter {

    // MARK: - Viper

    weak var transitionHandler: UIViewController?
    weak var output: BankCardDataInputRouterOutput?

    // MARK: - Init data

    fileprivate let cardScanner: CardScanning?

    // MARK: - Init

    init(cardScanner: CardScanning?) {
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
    func cardScannerDidFinish(_ cardInfo: ScannedCardInfo?) {
        transitionHandler?.dismiss(animated: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.cardScanner?.cardScanningDelegate = nil
            if let cardInfo = cardInfo {
                strongSelf.output?.cardScanningDidFinish(cardInfo)
            }
        }
    }
}
