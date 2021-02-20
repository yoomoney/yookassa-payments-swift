import UIKit
import protocol PassKit.PKPaymentAuthorizationViewControllerDelegate
import SafariServices

class TokenizationRouter: NSObject {

    // MARK: - VIPER

    weak var transitionHandler: TransitionHandler?
}

// MARK: - TokenizationRouterInput
extension TokenizationRouter: TokenizationRouterInput {

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

    func presentTermsOfServiceModule(_ url: URL) {
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .overFullScreen
        transitionHandler?.present(viewController, animated: true, completion: nil)
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
