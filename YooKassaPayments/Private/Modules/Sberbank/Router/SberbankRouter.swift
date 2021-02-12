import UIKit
import SafariServices

final class SberbankRouter {
    weak var transitionHandler: TransitionHandler?
}

// MARK: - SberbankRouterInput

extension SberbankRouter: SberbankRouterInput {
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
