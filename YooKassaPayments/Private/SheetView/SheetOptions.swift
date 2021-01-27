import UIKit

struct SheetOptions {
    let pullBarHeight: CGFloat = 24

    let animationDuration: Double = 0.3
    let animationOptions: UIView.AnimationOptions = [.curveEaseOut]

    let transitionDampening: CGFloat = 0.8
    let transitionVelocity: CGFloat = 0.5
    let transitionDuration: TimeInterval = 0.4

    let presentingViewCornerRadius: CGFloat = 12
}
