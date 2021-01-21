import UIKit.UIViewController

extension UIViewController: TransitionHandler {
    func push(
        _ viewController: UIViewController,
        animated flag: Bool
    ) {
        navigationController?.pushViewController(
            viewController,
            animated: flag
        )
    }
}
