import protocol YooKassaPayments.CardScanning
import struct YooKassaPayments.ScannedCardInfo
import CardIO

// MARK: - CardScanning

extension RootViewController: CardScanning {
    var cardScanningViewController: UIViewController? {

        guard let controller = CardIOPaymentViewController(paymentDelegate: self) else {
            return nil
        }

        controller.suppressScanConfirmation = true
        controller.hideCardIOLogo = true
        controller.disableManualEntryButtons = true
        controller.collectCVV = false

        return controller
    }
}

// MARK: - CardIOPaymentViewControllerDelegate

extension RootViewController: CardIOPaymentViewControllerDelegate {
    public func userDidProvide(_ cardInfo: CardIOCreditCardInfo!,
                               in paymentViewController: CardIOPaymentViewController!) {
        let scannedCardInfo = ScannedCardInfo(number: cardInfo.cardNumber,
                                              expiryMonth: "\(cardInfo.expiryMonth)",
                                              expiryYear: "\(cardInfo.expiryYear)")
        cardScanningDelegate?.cardScannerDidFinish(scannedCardInfo)
    }

    public func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        cardScanningDelegate?.cardScannerDidFinish(nil)
    }
}
