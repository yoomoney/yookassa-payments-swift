import FunctionalSwift
import UIKit

protocol PageSheetTemplateDelegate: class {
    func pageSheetTemplateDidFinish(_ template: PageSheetTemplate)
    func shouldPopNavigationItem()
}

class PageSheetTemplate: UIViewController {

    weak var delegate: PageSheetTemplateDelegate?

    // MARK: - UI properties

    lazy var dummyView: UIView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
        $0.layer.cornerRadius = Space.single
        return $0
    }(UIView())

    fileprivate lazy var viewTapGestureRecognizer: UITapGestureRecognizer = {
        $0.delegate = self
        return $0
    }(UITapGestureRecognizer(target: self, action: #selector(viewTapRecognizerHandle(_:))))

    var dummyViewBottomConstraint: NSLayoutConstraint?

    // MARK: - Configuring Navigation Bars

    lazy var navigationBar: UINavigationBar = {
        $0.setStyles(UINavigationBar.Styles.default)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        if #available(iOS 11.0, *) {
            $0.prefersLargeTitles = false
        }
        return $0
    }(UINavigationBar())

    private lazy var navigationBarConstraint = navigationBar.top.constraint(equalTo: dummyView.top)

    func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        navigationBarConstraint.isActive = false
        if hidden {
            navigationBarConstraint = navigationBar.bottom.constraint(equalTo: dummyView.top)
        } else {
            navigationBarConstraint = navigationBar.top.constraint(equalTo: dummyView.top)
        }

        navigationBarConstraint.isActive = true

        if animated {
            UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration),
                           animations: {
                               self.view.layoutIfNeeded()
                           })
        }
    }

    func setNavigationItems(_ items: [UINavigationItem]?, animated: Bool) {
        navigationBar.setItems(items, animated: animated)
        navigationBar.setNeedsLayout()
    }

    func pushNavigationItem(_ item: UINavigationItem, animated: Bool) {
        navigationBar.pushItem(item, animated: animated)
        navigationBar.setNeedsLayout()
    }

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.addGestureRecognizer(viewTapGestureRecognizer)
        view.backgroundColor = .clear
        KeyboardObservable.shared.addKeyboardObserver(self)
        loadSubviews()
        loadConstraints()
    }

    private func loadSubviews() {
        let subviews = [
            dummyView,
        ]

        dummyView.addSubview(navigationBar)

        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        view.addSubview <^> subviews
    }

    private func loadConstraints() {

        let heightConstraint = dummyView.height.constraint(equalToConstant: 394)
        let centerYConstraint = view.centerY.constraint(equalTo: dummyView.centerY)

        let topConstraint = dummyView.top.constraint(greaterThanOrEqualTo: view.topMargin)

        [
            heightConstraint,
            centerYConstraint,
        ].forEach { $0.priority = UILayoutPriority(rawValue: UILayoutPriority.required.rawValue - 1) }

        let constraints = [
            view.centerX.constraint(equalTo: dummyView.centerX),
            dummyView.width.constraint(equalToConstant: 450),
            topConstraint,
            centerYConstraint,
            heightConstraint,
            dummyView.leading.constraint(equalTo: navigationBar.leading),
            dummyView.trailing.constraint(equalTo: navigationBar.trailing),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func setContentView(_ view: UIView) {
        dummyView.insertSubview(view, belowSubview: navigationBar)

        let constraints = [
            dummyView.leading.constraint(equalTo: view.leading),
            dummyView.trailing.constraint(equalTo: view.trailing),
            navigationBar.bottom.constraint(equalTo: view.top),
            dummyView.bottom.constraint(equalTo: view.bottom),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions

    @objc
    func viewTapRecognizerHandle(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .recognized else { return }
        delegate?.pageSheetTemplateDidFinish(self)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension PageSheetTemplate: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === viewTapGestureRecognizer else { return true }
        return touch.view?.isDescendant(of: dummyView) == false
    }
}

// MARK: - KeyboardObserver

extension PageSheetTemplate: KeyboardObserver {
    func keyboardWillShow(with keyboardInfo: KeyboardNotificationInfo) {
        let viewFrame = view.convert(view.bounds, to: nil)
        guard viewFrame.isInfinite == false || viewFrame.isNull == false else { return }
        let intersection = viewFrame.intersection(keyboardInfo.endKeyboardFrame).height

        let bottomConstraint = dummyView.bottom.constraint(lessThanOrEqualTo: view.bottomMargin,
                                                           constant: -intersection)
        dummyViewBottomConstraint = bottomConstraint
        bottomConstraint.isActive = true

        let animation = {
            self.view.layoutIfNeeded()
        }

        if let duration = keyboardInfo.animationDuration {
            UIView.animate(withDuration: duration,
                           animations: animation)
        } else {
            animation()
        }
    }

    func keyboardDidShow(with keyboardInfo: KeyboardNotificationInfo) {
    }

    func keyboardWillHide(with keyboardInfo: KeyboardNotificationInfo) {
        dummyViewBottomConstraint?.isActive = false

        let animation = {
            self.view.layoutIfNeeded()
        }

        if let duration = keyboardInfo.animationDuration {
            UIView.animate(withDuration: duration,
                           animations: animation)
        } else {
            animation()
        }
    }

    func keyboardDidHide(with keyboardInfo: KeyboardNotificationInfo) {
    }

    func keyboardDidUpdateFrame(_ keyboardFrame: CGRect) {
    }
}

extension PageSheetTemplate: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        delegate?.shouldPopNavigationItem()
        return true
    }
}
