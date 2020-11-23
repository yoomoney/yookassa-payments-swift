import UIKit

/// Info from keyboard notification
class KeyboardNotificationInfo: NSObject { // Need NSObject to use in KeyboardObserver

    /// The starting frame rectangle of the keyboard in screen coordinates
    let beginKeyboardFrame: CGRect

    /// The ending frame rectangle of the keyboard in screen coordinates
    let endKeyboardFrame: CGRect

    /// UIViewAnimationCurve constant that defines how the keyboard will be animated onto or off the screen
    let animationCurve: UIView.AnimationCurve?

    /// Identifies the duration of the animation in seconds
    let animationDuration: TimeInterval?

    init(beginKeyboardFrame: CGRect,
         endKeyboardFrame: CGRect,
         animationCurve: UIView.AnimationCurve?,
         animationDuration: TimeInterval?) {
        self.beginKeyboardFrame = beginKeyboardFrame
        self.endKeyboardFrame = endKeyboardFrame
        self.animationCurve = animationCurve
        self.animationDuration = animationDuration
        super.init()
    }
}
