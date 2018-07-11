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
}
