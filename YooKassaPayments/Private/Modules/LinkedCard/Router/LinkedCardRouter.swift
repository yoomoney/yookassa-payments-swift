import SafariServices

final class LinkedCardRouter {
    weak var transitionHandler: TransitionHandler?
}

// MARK: - LinkedCardRouterInput

extension LinkedCardRouter: LinkedCardRouterInput {
    func presentTermsOfServiceModule(_ url: URL) {
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .overFullScreen
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
        transitionHandler?.push(
            viewController,
            animated: true
        )
    }
    
    func closePaymentAuthorization() {
        transitionHandler?.popTopViewController(animated: true)
    }
}
