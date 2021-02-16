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
    
    func popTopViewController(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }
    
    func replaceViewControllers(
        _ viewControllers: [UIViewController],
        animated: Bool
    ) {
        navigationController?.setViewControllers(
            viewControllers,
            animated: animated
        )
    }
}
