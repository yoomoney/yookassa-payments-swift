import SafariServices

final class ApplePayContractRouter {
    weak var transitionHandler: TransitionHandler?
}

// MARK: - ApplePayContractRouterInput

extension ApplePayContractRouter: ApplePayContractRouterInput {
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

    func presentApplePay(inputData: ApplePayModuleInputData, moduleOutput: ApplePayModuleOutput) {
        if let viewController = ApplePayAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        ) {
            moduleOutput.didPresentApplePayModule()
            transitionHandler?.present(
                viewController,
                animated: true,
                completion: nil
            )
        } else {
            moduleOutput.didFailPresentApplePayModule()
        }
    }

    func closeApplePay(completion: (() -> Void)?) {
        transitionHandler?.dismiss(
            animated: true,
            completion: completion
        )
    }
}
