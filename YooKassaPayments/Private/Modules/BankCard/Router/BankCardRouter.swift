import SafariServices

final class BankCardRouter {
    weak var transitionHandler: TransitionHandler?
    weak var output: BankCardDataInputRouterOutput?

    private let cardScanner: CardScanning?

    init(
        cardScanner: CardScanning?
    ) {
        self.cardScanner = cardScanner
    }
}

// MARK: - BankCardRouterInput

extension BankCardRouter: BankCardRouterInput {
    func presentTermsOfServiceModule(
        _ url: URL
    ) {
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .overFullScreen
        transitionHandler?.present(
            viewController,
            animated: true,
            completion: nil
        )
    }

    func presentSavePaymentMethodInfo(
        inputData: SavePaymentMethodInfoModuleInputData
    ) {
        let viewController = SavePaymentMethodInfoAssembly.makeModule(
            inputData: inputData
        )
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        transitionHandler?.present(
            navigationController,
            animated: true,
            completion: nil
        )
    }

    func openCardScanner() {
        guard let cardScanner = cardScanner,
              let viewController = cardScanner.cardScanningViewController,
              let transitionHandler = transitionHandler else { return }
        cardScanner.cardScanningDelegate = self
        transitionHandler.present(viewController, animated: true, completion: nil)
    }
}

// MARK: - CardScanningDelegate

extension BankCardRouter: CardScanningDelegate {
    func cardScannerDidFinish(_ cardInfo: ScannedCardInfo?) {
        transitionHandler?.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.cardScanner?.cardScanningDelegate = nil
            if let cardInfo = cardInfo {
                self.output?.cardScanningDidFinish(cardInfo)
            }
        }
    }
}
