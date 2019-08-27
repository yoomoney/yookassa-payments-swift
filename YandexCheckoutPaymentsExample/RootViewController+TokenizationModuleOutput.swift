import YandexCheckoutPayments
import YandexCheckoutPaymentsApi

// MARK: - TokenizationModuleOutput

extension RootViewController: TokenizationModuleOutput {
    func tokenizationModule(_ module: TokenizationModuleInput,
                            didTokenize token: Tokens,
                            paymentMethodType: PaymentMethodType) {

        self.token = token
        self.paymentMethodType = paymentMethodType

        let successViewController = SuccessViewController()
        successViewController.delegate = self

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if let presentedViewController = strongSelf.presentedViewController {
                presentedViewController.show(successViewController, sender: self)
            } else {
                strongSelf.present(successViewController, animated: true)
            }
        }
    }

    func didFinish(on module: TokenizationModuleInput,
                   with error: YandexCheckoutPaymentsError?) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.dismiss(animated: true)
        }
    }

    func didSuccessfullyPassedCardSec(on module: TokenizationModuleInput) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let alertController = UIAlertController(title: "3D-Sec",
                                                    message: "Successfully passed 3d-sec",
                                                    preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            strongSelf.dismiss(animated: true)
            strongSelf.present(alertController, animated: true)
        }
    }
}
