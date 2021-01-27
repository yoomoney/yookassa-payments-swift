import UIKit

final class SheetViewController: UIViewController {

    // MARK: - UI

    lazy var overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.backgroundColor = Constants.overlayColor
        return view
    }()

    private var overlayTapView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private weak var childScrollView: UIScrollView?

    // MARK: - UITapGestureRecognizer

    private lazy var overlayTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(overlayTapGestureRecognizerHandle)
        )
        return tapGestureRecognizer
    }()

    private lazy var initialTouchPanGestureRecognizer: InitialTouchPanGestureRecognizer = {
        let tapGestureRecognizer = InitialTouchPanGestureRecognizer(
            target: self,
            action: #selector(initialTouchPanGestureRecognizerHandle(_:))
        )
        tapGestureRecognizer.delegate = self
        return tapGestureRecognizer
    }()

    // MARK: - Logic properties

    private var keyboardHeight: CGFloat = 0

    private var firstPanPoint: CGPoint = .zero
    private var prePanHeight: CGFloat = 0
    private var isPanning = false

    // MARK: - NSLayoutConstraint

    private var contentViewHeightConstraint: NSLayoutConstraint!

    // MARK: - Initialization

    private let contentViewController: SheetContentViewController
    private let transition: SheetTransition
    private let sheetOptions: SheetOptions

    init(
        contentViewController: UIViewController,
        sheetViewModel: SheetViewModel = .default,
        sheetOptions: SheetOptions = SheetOptions()
    ) {
        self.contentViewController = SheetContentViewController(
            childViewController: contentViewController,
            sheetViewModel: sheetViewModel,
            options: sheetOptions
        )
        self.sheetOptions = sheetOptions

        transition = SheetTransition(
            contentViewController: self.contentViewController,
            options: sheetOptions
        )
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Managing the View

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clear

        setupAdditionalSafeAreaInsets()
        setupGestureRecognizers()
        setupOverlayView()
        setupContentView()
        setupOverlayTapView()
        registerKeyboardObservers()
        resize(
            to: .intrinsic,
            duration: sheetOptions.animationDuration,
            options: sheetOptions.animationOptions
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentViewController.updatePreferredHeight()
        resize(
            to: .intrinsic,
            duration: sheetOptions.animationDuration,
            options: sheetOptions.animationOptions
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let presenter = transition.presenter {
            transition.restorePresenter(presenter)
        }
    }

    // MARK: - SetupView

    private func setupAdditionalSafeAreaInsets() {
        if #available(iOS 11.0, *) {
            additionalSafeAreaInsets = UIEdgeInsets(
                top: -sheetOptions.pullBarHeight,
                left: 0,
                bottom: 0,
                right: 0
            )
        }
    }

    private func setupGestureRecognizers() {
        view.addGestureRecognizer(initialTouchPanGestureRecognizer)
    }

    private func setupOverlayView() {
        view.addSubview(overlayView)
        let constraints = [
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func setupContentView() {
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentViewController.willMove(toParent: self)
        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)
        contentViewController.delegate = self
        contentViewHeightConstraint = contentViewController.view.heightAnchor.constraint(
            equalToConstant: height(for: .intrinsic)
        )
        let leftLowPriorityConstraint = contentViewController.view.leadingAnchor.constraint(
            equalTo: view.leadingAnchor
        )
        leftLowPriorityConstraint.priority = .highest

        let leftGreaterThanOrEqualToConstraint = contentViewController.view.leadingAnchor.constraint(
            greaterThanOrEqualTo: view.leadingAnchor
        )
        let topConstraint = contentViewController.view.topAnchor.constraint(
            greaterThanOrEqualTo: view.topAnchor
        )
        topConstraint.priority = .highest
        var constraints = [
            leftLowPriorityConstraint,
            leftGreaterThanOrEqualToConstraint,
            contentViewController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            topConstraint,
        ]
        if let contentViewHeightConstraint = contentViewHeightConstraint {
            constraints += [
                contentViewHeightConstraint,
            ]
        }
        NSLayoutConstraint.activate(constraints)
    }

    private func setupOverlayTapView() {
        view.addSubview(overlayTapView)
        let constraints = [
            overlayTapView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayTapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayTapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayTapView.bottomAnchor.constraint(equalTo: contentViewController.view.topAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        overlayTapView.addGestureRecognizer(overlayTapGestureRecognizer)
    }

    private func registerKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardShown(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDismissed(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}

// MARK: - Internal helpers

extension SheetViewController {
    func handleScrollView(
        _ scrollView: UIScrollView
    ) {
        scrollView.panGestureRecognizer.require(
            toFail: initialTouchPanGestureRecognizer
        )
        childScrollView = scrollView
    }

    func resize(
        to size: SheetSize,
        duration: TimeInterval,
        options: UIView.AnimationOptions,
        animated: Bool = true,
        complete: (() -> Void)? = nil
    ) {
        let oldHeightConstraint = contentViewHeightConstraint.constant
        let newHeightConstraint = height(for: size)

        guard oldHeightConstraint != newHeightConstraint else {
            return
        }

        if animated {
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: options,
                animations: { [weak self] in
                    guard let self = self,
                          let constraint = self.contentViewHeightConstraint else {
                        return
                    }
                    constraint.constant = newHeightConstraint
                    self.view.layoutIfNeeded()
                },
                completion: { _ in
                    complete?()
                })
        } else {
            UIView.performWithoutAnimation { [weak self] in
                guard let self = self else { return }
                self.contentViewHeightConstraint?.constant = self.height(for: size)
                self.contentViewController.view.layoutIfNeeded()
            }
            complete?()
        }
    }
}

// MARK: - Private helpers

private extension SheetViewController {
    func height(
        for size: SheetSize
    ) -> CGFloat {
        let fullscreenHeight = view.bounds.height

        let contentHeight: CGFloat
        switch size {
        case .fullscreen:
            contentHeight = fullscreenHeight
        case .intrinsic:
            contentHeight = contentViewController.preferredHeight
                + keyboardHeight
        }
        return min(fullscreenHeight, contentHeight)
    }

    func attemptDismiss(animated: Bool) {
        dismiss(animated: animated, completion: nil)
    }

}

// MARK: - Gesture actions

@objc
private extension SheetViewController {
    func overlayTapGestureRecognizerHandle(
        _ sender: UITapGestureRecognizer
    ) {
        attemptDismiss(animated: true)
    }

    func initialTouchPanGestureRecognizerHandle(
        _ sender: UIPanGestureRecognizer
    ) {
        let point = sender.translation(in: sender.view?.superview)
        if sender.state == .began {
            firstPanPoint = point
            prePanHeight = contentViewController.view.bounds.height
            isPanning = true
        }

        let minHeight: CGFloat = height(for: .intrinsic)
        let maxHeight = height(for: .fullscreen)

        var newHeight = max(0, prePanHeight + (firstPanPoint.y - point.y))
        var offset: CGFloat = 0
        if newHeight < minHeight {
            offset = minHeight - newHeight
            newHeight = minHeight
        }
        if newHeight > maxHeight {
            newHeight = maxHeight
        }

        switch sender.state {
        case .cancelled, .failed:
            UIView.animate(
                withDuration: sheetOptions.animationDuration,
                delay: 0,
                options: sheetOptions.animationOptions,
                animations: {
                    self.contentViewController.view.transform = CGAffineTransform.identity
                    self.contentViewHeightConstraint.constant = self.height(for: .intrinsic)
                    self.transition.setPresenter(percentComplete: 0)
                    self.overlayView.alpha = 1
                },
                completion: { _ in
                    self.isPanning = false
                })

        case .began, .changed:
            contentViewHeightConstraint.constant = newHeight

            if offset > 0 {
                let percent = max(0, min(1, offset / max(1, newHeight)))
                transition.setPresenter(percentComplete: percent)
                overlayView.alpha = 1 - percent
                contentViewController.view.transform = CGAffineTransform(translationX: 0, y: offset)
            } else {
                contentViewController.view.transform = CGAffineTransform.identity
            }
        case .ended:
            let velocity = (0.2 * sender.velocity(in: view).y)
            var finalHeight = newHeight - offset - velocity
            if velocity > 500 {
                finalHeight = -1
            }

            let animationDuration = TimeInterval(abs(velocity * 0.0002) + 0.2)

            guard finalHeight > 0 else {
                UIView.animate(
                    withDuration: animationDuration,
                    delay: 0,
                    usingSpringWithDamping: sheetOptions.transitionDampening,
                    initialSpringVelocity: sheetOptions.transitionVelocity,
                    options: sheetOptions.animationOptions,
                    animations: {
                        self.contentViewController.view.transform = CGAffineTransform(
                            translationX: 0,
                            y: self.contentViewController.view.bounds.height
                        )
                        self.view.backgroundColor = UIColor.clear
                        self.transition.setPresenter(percentComplete: 1)
                        self.overlayView.alpha = 0
                    },
                    completion: { complete in
                        self.attemptDismiss(animated: false)
                    })
                return
            }

            let newContentHeight = height(for: .intrinsic)
            UIView.animate(
                withDuration: animationDuration,
                delay: 0,
                usingSpringWithDamping: sheetOptions.transitionDampening,
                initialSpringVelocity: sheetOptions.transitionVelocity,
                options: sheetOptions.animationOptions,
                animations: {
                    self.contentViewController.view.transform = CGAffineTransform.identity
                    self.contentViewHeightConstraint.constant = newContentHeight
                    self.transition.setPresenter(percentComplete: 0)
                    self.overlayView.alpha = 1
                    self.view.layoutIfNeeded()
                },
                completion: { complete in
                    self.isPanning = false
                })
        case .possible:
            break
        @unknown default:
            break
        }
    }
}

// MARK: - Keyboard actions

@objc
private extension SheetViewController {
    func keyboardShown(
        _ notification: Notification
    ) {
        guard let info: [AnyHashable: Any] = notification.userInfo,
              let keyboardRect: CGRect = (
                  info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
              )?.cgRectValue else { return }

        let windowRect = view.convert(view.bounds, to: nil)
        let actualHeight = windowRect.maxY - keyboardRect.origin.y
        adjustForKeyboard(height: actualHeight, from: notification)
    }

    func keyboardDismissed(
        _ notification: Notification
    ) {
        adjustForKeyboard(height: 0, from: notification)
    }

    func adjustForKeyboard(
        height: CGFloat,
        from notification: Notification
    ) {
        guard let info: [AnyHashable: Any] = notification.userInfo else { return }
        keyboardHeight = height

        let duration: TimeInterval = (
            info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        )?.doubleValue ?? 0
        let animationCurveRawNSN = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?
            .uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)

        contentViewController.adjustForKeyboard(height: keyboardHeight)
        resize(to: .intrinsic, duration: duration, options: animationCurve, animated: true, complete: {
            self.resize(
                to: .intrinsic,
                duration: self.sheetOptions.animationDuration,
                options: self.sheetOptions.animationOptions
            )
        })
    }
}

// MARK: - Constants

private extension SheetViewController {
    enum Constants {
        static let overlayColor = UIColor(white: 0, alpha: 0.25)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension SheetViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        true
    }

    func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? InitialTouchPanGestureRecognizer,
              let childScrollView = childScrollView,
              let point = panGestureRecognizer.initialTouchLocation else { return true }

        let pointInChildScrollView = view.convert(point, to: childScrollView).y
            - childScrollView.contentOffset.y

        let velocity = panGestureRecognizer.velocity(in: panGestureRecognizer.view?.superview)
        guard pointInChildScrollView > 0,
              pointInChildScrollView < childScrollView.bounds.height else {
            if keyboardHeight > 0 {
                childScrollView.endEditing(true)
            }
            return true
        }
        let topInset = childScrollView.contentInset.top

        guard abs(velocity.y) > abs(velocity.x),
              childScrollView.contentOffset.y <= -topInset else { return false }

        if velocity.y < 0 {
            let containerHeight = height(for: .intrinsic)
            return height(for: .intrinsic) > containerHeight && containerHeight < height(for: .fullscreen)
        } else {
            return true
        }
    }
}

// MARK: - SheetContentViewDelegate

extension SheetViewController: SheetContentViewDelegate {
    func preferredHeightChanged(
        oldHeight: CGFloat,
        newSize: CGFloat
    ) {
        if !isPanning {
            resize(
                to: .intrinsic,
                duration: sheetOptions.animationDuration,
                options: sheetOptions.animationOptions
            )
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension SheetViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = true
        return transition
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}
