import SafariServices

final class YooMoneyRouter {
    weak var transitionHandler: TransitionHandler?
}

// MARK: - YooMoneyRouterInput

extension YooMoneyRouter: YooMoneyRouterInput {
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
    
    func presentPaymentAuthorizationModule(
        inputData: PaymentAuthorizationModuleInputData,
        moduleOutput: PaymentAuthorizationModuleOutput?
    ) {
        let viewController = PaymentAuthorizationAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
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
    
    func closePaymentAuthorization() {
        transitionHandler?.dismiss(
            animated: true,
            completion: nil
        )
    }
}
