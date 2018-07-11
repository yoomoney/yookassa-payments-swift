import UIKit.NSLayoutConstraint
import UIKit.UIViewController

/// Support of pinned to keyboard view.
protocol KeyboardPinning {

    /// Bottom constraint of pinned view. Should be pinned to bottom layout guide with constant value.
    var pinnedViewBottomConstraint: NSLayoutConstraint { get }

    /// Update layout for pinned view according to keyboard frame update.
    func updatePinnedViewLayout(with keyboardFrame: CGRect)
}

/// Default implementation for UIViewController
extension KeyboardPinning where Self: UIViewController, Self: KeyboardObserver {
    func updatePinnedViewLayout(with keyboardFrame: CGRect) {
        guard let keyboardOffset = keyboardYOffset(from: keyboardFrame) else { return }
        pinnedViewBottomConstraint.constant = -keyboardOffset
        view.layoutIfNeeded()
    }
}
