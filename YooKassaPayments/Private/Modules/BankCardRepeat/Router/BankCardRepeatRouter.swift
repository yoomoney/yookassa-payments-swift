import SafariServices

final class BankCardRepeatRouter {
    weak var transitionHandler: TransitionHandler?
}

// MARK: - BankCardRepeatRouterInput

extension BankCardRepeatRouter: BankCardRepeatRouterInput {
    func presentTermsOfServiceModule(_ url: URL) {
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
}
