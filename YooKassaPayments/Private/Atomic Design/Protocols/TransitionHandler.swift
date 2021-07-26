import UIKit

protocol TransitionHandler: AnyObject {

    /// Presents a view controller modal.
    ///
    /// - Parameters:
    ///   - viewControllerToPresent: view controller to present
    ///   - flag: manage animation flag
    ///   - completion: The block to execute after the presentation finishes.
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)

    /// Dismisses the view controller that was presented modally by top view controller.
    ///
    /// - Parameters:
    ///   - flag: manage animation flag
    ///   - completion: The block to execute after the dismiss finishes.
    func dismiss(animated flag: Bool, completion: (() -> Void)?)

    /// Pops the top view controller from the navigation stack and updates the display.
    /// - Parameters:
    ///     - animated: Set this value to true to animate the transition.
    func popTopViewController(animated: Bool)

    /// When you present a view controller modally (either explicitly or implicitly)
    /// using the present(_:animated:completion:) method, the view controller that called the
    /// method has this property set to the view controller that it presented.
    /// If the current view controller did not present another view controller modally,
    /// the value in this property is nil.
    var presentedViewController: UIViewController? { get }

    /// Push a view controller in navigation controller.
    /// - Parameters:
    ///   - viewController: view controller to push
    ///   - flag: manage animation flag
    func push(_ viewController: UIViewController, animated flag: Bool)
}
