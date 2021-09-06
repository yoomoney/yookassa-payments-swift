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

    func presentSafeDealInfo(title: String, body: String) {
        presentSavePaymentMethodInfo(inputData: .init(headerValue: title, bodyValue: body))
    }

    func presentSavePaymentMethodInfo(inputData: SavePaymentMethodInfoModuleInputData) {
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

    func present3dsModule(inputData: CardSecModuleInputData, moduleOutput: CardSecModuleOutput) {
        let viewController = CardSecAssembly.makeModule(
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

    func closeCardSecModule() {
        transitionHandler?.dismiss(
            animated: true,
            completion: nil
        )
    }
}
