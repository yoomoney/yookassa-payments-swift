import SafariServices
import UIKit

final class SberbankRouter {
    weak var transitionHandler: TransitionHandler?
}

// MARK: - SberbankRouterInput

extension SberbankRouter: SberbankRouterInput {
    func presentTermsOfServiceModule(_ url: URL) {
        guard url.scheme == "http" || url.scheme == "https" else { return }
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .overFullScreen
        transitionHandler?.present(
            viewController,
            animated: true,
            completion: nil
        )
    }

    func presentSafeDealInfo(title: String, body: String) {
        let viewController = SavePaymentMethodInfoAssembly.makeModule(
            inputData: .init(headerValue: title, bodyValue: body)
        )
        let navigationController = UINavigationController(rootViewController: viewController)
        transitionHandler?.present(
            navigationController,
            animated: true,
            completion: nil
        )
    }
}
