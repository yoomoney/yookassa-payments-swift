import UIKit
import protocol PassKit.PKPaymentAuthorizationViewControllerDelegate
import SafariServices

class TokenizationRouter: NSObject {

    // MARK: - VIPER

    weak var transitionHandler: TransitionHandler?
}

// MARK: - TokenizationRouterInput
extension TokenizationRouter: TokenizationRouterInput {
    func presentPaymentMethods(
        inputData: PaymentMethodsModuleInputData,
        moduleOutput: PaymentMethodsModuleOutput
    ) {
        let viewController = PaymentMethodsAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(viewController, animated: true)
    }

    func presentContract(
        inputData: ContractModuleInputData,
        moduleOutput: ContractModuleOutput
    ) {
        let viewController = ContractAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(viewController, animated: true)
    }

    func presentSberbank(
        inputData: SberbankModuleInputData,
        moduleOutput: SberbankModuleOutput
    ) {
        let viewController = SberbankAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(viewController, animated: true)
    }

    func presentBankCardDataInput(
        inputData: BankCardDataInputModuleInputData,
        moduleOutput: BankCardDataInputModuleOutput
    ) {
        let viewController = BankCardDataInputAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(viewController, animated: true)
    }

    func presenMaskedBankCardDataInput(
        inputData: MaskedBankCardDataInputModuleInputData,
        moduleOutput: MaskedBankCardDataInputModuleOutput
    ) {
        let viewController = MaskedBankCardDataInputAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(viewController, animated: true)
    }

    func presentWalletAuthParameters(
        inputData: WalletAuthParametersModuleInputData,
        moduleOutput: WalletAuthParametersModuleOutput
    ) {
        let viewController = WalletAuthParametersAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(viewController, animated: true)
    }

    func presentWalletAuth(
        inputData: WalletAuthModuleInputData,
        moduleOutput: WalletAuthModuleOutput
    ) {
        let viewController = WalletAuthAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(viewController, animated: true)
    }

    func presentLogoutConfirmation(
        inputData: LogoutConfirmationModuleInputData,
        moduleOutput: LogoutConfirmationModuleOutput
    ) {
        let viewController = LogoutConfirmationAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.present(
            viewController,
            animated: true,
            completion: nil
        )
    }

    func present3dsModule(
        inputData: CardSecModuleInputData,
        moduleOutput: CardSecModuleOutput
    ) {
        let viewController = CardSecAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(viewController, animated: true)
    }

    func presentYooMoneyAuth(
        inputData: YooMoneyAuthModuleInputData,
        moduleOutput: YooMoneyAuthModuleOutput
    ) {
        let viewController = YooMoneyAuthAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(viewController, animated: true)
    }

    func presentApplePay(
        inputData: ApplePayModuleInputData,
        moduleOutput: ApplePayModuleOutput
    ) {
        if let viewController = ApplePayAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        ) {
            moduleOutput.didPresentApplePayModule()
            transitionHandler?.present(viewController, animated: true, completion: nil)
        } else {
            moduleOutput.didFailPresentApplePayModule()
        }
    }

    func presentError(
        inputData: ErrorModuleInputData,
        moduleOutput: ErrorModuleOutput
    ) {
        let viewController = ErrorAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.present(viewController, animated: true, completion: nil)
    }

    func presentTermsOfServiceModule(_ url: URL) {
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .overFullScreen
        transitionHandler?.present(viewController, animated: true, completion: nil)
    }

    func presentApplePayContract(
        inputData: ApplePayContractModuleInputData,
        moduleOutput: ApplePayContractModuleOutput
    ) {
        let viewController = ApplePayContractAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(viewController, animated: true)
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
}
