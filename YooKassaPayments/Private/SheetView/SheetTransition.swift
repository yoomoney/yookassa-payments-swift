import UIKit

final class SheetTransition: NSObject {

    // MARK: - Internal properties

    weak var presenter: UIViewController?
    var presenting = true

    private var extendedLayoutIncludesOpaqueBars: Bool?

    // MARK: - Initialization

    private let contentViewController: SheetContentViewController
    private let options: SheetOptions

    init(
        contentViewController: SheetContentViewController,
        options: SheetOptions
    ) {
        self.contentViewController = contentViewController
        self.options = options
        super.init()
    }
}

// MARK: - Internal helpers

extension SheetTransition {
    func restorePresenter(
        _ presenter: UIViewController,
        animated: Bool = true,
        animations: (() -> Void)? = nil,
        completion: ((Bool) -> Void)? = nil
    ) {
        extendedLayoutIncludesOpaqueBars.map {
            presenter.extendedLayoutIncludesOpaqueBars = $0
        }
        UIView.animate(
            withDuration: options.transitionDuration,
            animations: {
                presenter.view.layer.transform = CATransform3DIdentity
                presenter.view.layer.cornerRadius = 0
                animations?()
            },
            completion: {
                completion?($0)
            }
        )
    }

    func setPresenter(
        percentComplete: CGFloat
    ) {
        guard let presenter = presenter else { return }
        let scale: CGFloat = min(1, 0.92 + (0.08 * percentComplete))

        let topSafeArea: CGFloat
        if #available(iOS 11.0, *) {
            topSafeArea = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 0
        } else {
            topSafeArea = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.layoutMargins.top ?? 0
        }

        presenter.view.layer.transform = CATransform3DConcat(
            CATransform3DMakeTranslation(0, (1 - percentComplete) * topSafeArea / 2, 0),
            CATransform3DMakeScale(scale, scale, 1)
        )
        presenter.view.layer.cornerRadius = options.presentingViewCornerRadius * (1 - percentComplete)
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension SheetTransition: UIViewControllerAnimatedTransitioning {
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        let containerView = transitionContext.containerView
        if presenting {
            guard let presenter = transitionContext.viewController(forKey: .from),
                  let sheet = transitionContext.viewController(forKey: .to) as? SheetViewController else {
                transitionContext.completeTransition(true)
                return
            }
            self.presenter = presenter

            if
                !UINavigationBar.appearance().isTranslucent,
                presenter.extendedLayoutIncludesOpaqueBars == false,
                let container = presenter as? UINavigationController,
                let top = container.topViewController,
                container.navigationBar.backgroundImage(for: .default) == nil
            {
                top.extendedLayoutIncludesOpaqueBars = true
                extendedLayoutIncludesOpaqueBars = false
            }

            contentViewController.view.transform = .identity
            containerView.addSubview(sheet.view)
            sheet.view.setNeedsLayout()
            sheet.view.layoutIfNeeded()
            contentViewController.updatePreferredHeight()
            sheet.resize(to: .intrinsic, duration: options.animationDuration, options: options.animationOptions)
            let contentView = contentViewController.contentView
            contentView.transform = CGAffineTransform(translationX: 0, y: contentView.bounds.height)
            sheet.overlayView.alpha = 0

            let heightPercent = contentView.bounds.height / UIScreen.main.bounds.height

            // Animate shadow and background view
            UIView.animate(
                withDuration: options.transitionDuration * 0.6,
                delay: 0,
                options: [.curveEaseOut],
                animations: {
                    let topSafeArea: CGFloat
                    if #available(iOS 11.0, *) {
                        topSafeArea = UIApplication.shared.windows
                            .first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 0
                    } else {
                        topSafeArea = UIApplication.shared.windows
                            .first(where: { $0.isKeyWindow })?.layoutMargins.top ?? 0
                    }

                    presenter.view.layer.transform = CATransform3DConcat(
                        CATransform3DMakeTranslation(0, topSafeArea / 2, 0),
                        CATransform3DMakeScale(0.92, 0.92, 1)
                    )
                    presenter.view.layer.cornerRadius = self.options.presentingViewCornerRadius
                    presenter.view.layer.masksToBounds = true

                    sheet.overlayView.alpha = 1
                },
                completion: nil
            )

            // Animate the view in
            UIView.animate(
                withDuration: options.transitionDuration,
                delay: 0,
                usingSpringWithDamping: options.transitionDampening + ((heightPercent - 0.2) * 1.25 * 0.17),
                initialSpringVelocity: options.transitionVelocity * heightPercent,
                options: options.animationOptions,
                animations: {
                    contentView.transform = .identity
                },
                completion: { _ in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            )
        } else {
            guard let presenter = transitionContext.viewController(forKey: .to),
                  let sheet = transitionContext.viewController(forKey: .from) as? SheetViewController else {
                transitionContext.completeTransition(true)
                return
            }

            containerView.addSubview(sheet.view)
            let contentView = contentViewController.contentView

            restorePresenter(
                presenter,
                animations: {
                    contentView.transform = CGAffineTransform(
                        translationX: 0,
                        y: contentView.bounds.height
                    )
                    sheet.overlayView.alpha = 0
                },
                completion: { _ in
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            )
        }
    }

    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        options.transitionDuration
    }
}
