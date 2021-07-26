import SafariServices
import UIKit

final class SberpayRouter {
    weak var transitionHandler: TransitionHandler?
}

// MARK: - SberpayRouterInput

extension SberpayRouter: SberpayRouterInput {
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
}
