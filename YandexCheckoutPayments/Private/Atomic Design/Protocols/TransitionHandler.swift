import UIKit.UIViewController

protocol TransitionHandler: class {

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

    /// When you present a view controller modally (either explicitly or implicitly)
    /// using the present(_:animated:completion:) method, the view controller that called the
    /// method has this property set to the view controller that it presented.
    /// If the current view controller did not present another view controller modally,
    /// the value in this property is nil.
    var presentedViewController: UIViewController? { get }
}
