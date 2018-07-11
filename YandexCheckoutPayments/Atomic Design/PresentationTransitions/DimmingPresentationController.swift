import UIKit.UIColor
import UIKit.UIPresentationController
import UIKit.UIView

/// Presentation controller with add dimming view
class DimmingPresentationController: UIPresentationController {

    var preferredBackgroundColor = UIColor(white: 0, alpha: 0.4)

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }

        setupDimmingView()

        guard let dimmingView = dimmingView else { return }

        containerView.addSubview(dimmingView)
        dimmingView.backgroundColor = preferredBackgroundColor

        let constraints = [
            dimmingView.top.constraint(equalTo: containerView.top),
            dimmingView.leading.constraint(equalTo: containerView.leading),
            dimmingView.trailing.constraint(equalTo: containerView.trailing),
            dimmingView.bottom.constraint(equalTo: containerView.bottom),
        ]
        NSLayoutConstraint.activate(constraints)

        presentedView?.autoresizingMask = [
            .flexibleLeftMargin,
            .flexibleRightMargin,
            .flexibleTopMargin,
            .flexibleBottomMargin,
            .flexibleWidth,
            .flexibleHeight,
        ]

        dimmingView.alpha = 0
        let alpha: CGFloat = 1
        guard let coordinator = presentingViewController.transitionCoordinator else {
            dimmingView.alpha = alpha
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = alpha
        })
    }

    override func dismissalTransitionWillBegin() {
        let alpha: CGFloat = 0
        guard let coordinator = presentingViewController.transitionCoordinator else {
            dimmingView?.alpha = alpha
            return
        }
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = alpha
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        guard completed == false else { return }
        dimmingView?.removeFromSuperview()
        dimmingView = nil
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        guard completed else { return }
        dimmingView?.removeFromSuperview()
        dimmingView = nil
    }

    private var dimmingView: UIView?

    private func setupDimmingView() {
        dimmingView?.removeFromSuperview()
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        dimmingView = view
    }
}
