import SafariServices

final class BankCardRouter {
    weak var transitionHandler: TransitionHandler?
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
}
