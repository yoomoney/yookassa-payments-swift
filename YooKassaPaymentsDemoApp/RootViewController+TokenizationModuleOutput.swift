import UIKit
import YooKassaPayments

// MARK: - TokenizationModuleOutput

extension RootViewController: TokenizationModuleOutput {
    func tokenizationModule(
        _ module: TokenizationModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    ) {
        self.token = token
        self.paymentMethodType = paymentMethodType

        if settings.testModeSettings.isTestModeEnadled,
           let processConfirmation = settings.testModeSettings.processConfirmation {
            switch processConfirmation {
            case let .threeDSecure(requestUrl):
                tokenizationModuleInput?.startConfirmationProcess(
                    confirmationUrl: requestUrl,
                    paymentMethodType: paymentMethodType
                )

            case let .app2app(confirmationUrl):
                tokenizationModuleInput?.startConfirmationProcess(
                    confirmationUrl: confirmationUrl,
                    paymentMethodType: paymentMethodType
                )
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.dismiss(animated: true)

                let successViewController = SuccessViewController()
                let navigationController = UINavigationController(
                    rootViewController: successViewController
                )
                successViewController.delegate = self
                self.present(navigationController, animated: true)
            }
        }
    }

    func didFinish(
        on module: TokenizationModuleInput,
        with error: YooKassaPaymentsError?
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
    }

    func didSuccessfullyPassedCardSec(
        on module: TokenizationModuleInput
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alertController = UIAlertController(
                title: "3D-Sec",
                message: "Successfully passed 3d-sec",
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            self.dismiss(animated: true)
            self.present(alertController, animated: true)
        }
    }

    func didSuccessfullyConfirmation(
        paymentMethodType: PaymentMethodType
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alertController = UIAlertController(
                title: "Confirmation",
                message: "Successfully confirmation",
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(action)
            self.dismiss(animated: true)
            self.present(alertController, animated: true)
        }
    }
}
