import UIKit

/// Controller for scroll view.
/// This controller subscribes for keyboard events and automatically increases and decreases the insets
/// of UIScrollView's content and scrollIndicator when the keyboard appears and disappears.
///
/// It's recommended to use this controller instead of `UIScrollView`.
class ScrollViewController: UIViewController {

    /// Scroll view. All scrollable content must be placed in it.
    private(set) lazy var scrollView = UIScrollView()

    /// Header view, that is shown at top of the screen. Is not scrollable.
    var headerView: UIView? {
        didSet {
            guard headerView !== oldValue else { return }

            if let oldHeaderView = oldValue {
                removeHeaderView(oldHeaderView)
            }
            if let newHeaderView = headerView {
                addHeaderView(newHeaderView)
            }
        }
    }

    var headerInsets: UIEdgeInsets = .zero

    /// Footer view, that is shown at bottom of screen. Is not scrollable.
    /// - Note: footerView is pinned to keyboard and updates it's frame on keyboard events.
    var footerView: UIView? {
        didSet {
            guard footerView !== oldValue else { return }

            if let oldFooterView = oldValue {
                removeFooterView(oldFooterView)
            }
            if let newFooterView = footerView {
                addFooterView(newFooterView)
            }
        }
    }

    var footerInsets: UIEdgeInsets = .zero

    // MARK: - Private properties

    fileprivate var originalScrollInsets: UIEdgeInsets?

    fileprivate var currentKeyboardOffset: CGFloat?

    fileprivate lazy var scrollViewToTopPinConstraint: NSLayoutConstraint = {
        return $0
    }(self.scrollView.top.constraint(equalTo: self.view.top))

    fileprivate lazy var scrollViewToBottomPinConstraint: NSLayoutConstraint = {
        return $0
    }(self.scrollView.bottom.constraint(equalTo: self.view.bottom))

    fileprivate var bottomFooterConstraint: NSLayoutConstraint?

    // MARK: - Managing the View
    override func loadView() {
        view = UIView()
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        setupBasicConstraints()
    }

    // MARK: - Responding to View Events
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startKeyboardObserving()
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopKeyboardObserving()
        super.viewWillDisappear(animated)
    }
}

// MARK: - KeyboardObserving
extension ScrollViewController: KeyboardObserver {
    func keyboardWillShow(with keyboardInfo: KeyboardNotificationInfo) {
        let keyboardOffset = updateBottomConstraint(keyboardInfo)
        currentKeyboardOffset = keyboardOffset
    }

    func keyboardWillHide(with keyboardInfo: KeyboardNotificationInfo) {
        updateBottomConstraint(keyboardInfo)
        currentKeyboardOffset = nil
    }

    func keyboardDidShow(with keyboardInfo: KeyboardNotificationInfo) {}
    func keyboardDidHide(with keyboardInfo: KeyboardNotificationInfo) {}
    func keyboardDidUpdateFrame(_ keyboardFrame: CGRect) {}

    @discardableResult
    private func updateBottomConstraint(
        _ keyboardInfo: KeyboardNotificationInfo
    ) -> CGFloat? {
        guard let keyboardOffset = keyboardYOffset(from: keyboardInfo.endKeyboardFrame) else {
            return nil
        }
        if let bottomConstraint = bottomFooterConstraint {
            let duration = keyboardInfo.animationDuration ?? 0.3

            var options: UIView.AnimationOptions = []
            if let animationCurve = keyboardInfo.animationCurve {
                options = UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue))
            }

            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: options,
                animations: { [weak self] in
                    guard let self = self else { return }
                    bottomConstraint.constant = -keyboardOffset - self.footerInsets.bottom
                    self.view.layoutIfNeeded()
                },
                completion: nil)
        } else {
            updateScrollInsets(byKeyboardOffset: keyboardOffset)
        }
        return keyboardOffset
    }
}

// MARK: - Managing the Content Inset Behavior
private extension ScrollViewController {
    func updateScrollInsets(byKeyboardOffset keyboardOffset: CGFloat) {
        if originalScrollInsets == nil {
            originalScrollInsets = scrollView.contentInset
        }

        let defaultInsets = originalScrollInsets ?? UIEdgeInsets.zero
        if keyboardOffset > 0 {
            scrollView.contentInset = UIEdgeInsets(top: defaultInsets.top,
                                                   left: defaultInsets.left,
                                                   bottom: keyboardOffset,
                                                   right: defaultInsets.right)

        } else {
            scrollView.contentInset = defaultInsets
            originalScrollInsets = nil
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }

    func removeScrollInsetsForKeyboard() {
        updateScrollInsets(byKeyboardOffset: 0)
    }
}

// MARK: - Configuring the View’s Layout Behavior
private extension ScrollViewController {
    func setupBasicConstraints() {
        NSLayoutConstraint.activate([
            scrollViewToTopPinConstraint,
            scrollViewToBottomPinConstraint,
            scrollView.leading.constraint(equalTo: view.leading),
            scrollView.trailing.constraint(equalTo: view.trailing),
        ])

        scrollView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }

    func updateHeaderViewConstraints() {
        guard let headerView = headerView, headerView.superview != nil else {
            scrollViewToTopPinConstraint.isActive = true
            return
        }

        scrollViewToTopPinConstraint.isActive = false

        NSLayoutConstraint.activate([
            headerView.top.constraint(equalTo: view.top, constant: headerInsets.top),
            headerView.bottom.constraint(equalTo: scrollView.top, constant: -headerInsets.bottom),
            headerView.leading.constraint(equalTo: view.leading, constant: headerInsets.left),
            headerView.trailing.constraint(equalTo: view.trailing, constant: -headerInsets.right),
        ])
    }

    func updateFooterViewConstraints() {
        guard let footerView = footerView, footerView.superview != nil else {
            scrollViewToBottomPinConstraint.isActive = true
            bottomFooterConstraint = nil
            return
        }

        scrollViewToBottomPinConstraint.isActive = false

        let bottomConstraint: NSLayoutConstraint
        if #available(iOS 9, *) {
            bottomConstraint = footerView.bottomAnchor.constraint(equalTo: view.specificLayoutGuide.bottomAnchor,
                                                                  constant: -footerInsets.bottom)
        } else {
            bottomConstraint = footerView.bottom.constraint(equalTo: view.bottom,
                                                            constant: -footerInsets.bottom)
        }
        if let keyboardOffset = currentKeyboardOffset {
            bottomConstraint.constant = -keyboardOffset - footerInsets.bottom
        }

        bottomFooterConstraint = bottomConstraint

        NSLayoutConstraint.activate([
            footerView.top.constraint(equalTo: scrollView.bottom, constant: footerInsets.top),
            bottomConstraint,
            footerView.leading.constraint(equalTo: view.leading, constant: footerInsets.left),
            footerView.trailing.constraint(equalTo: view.trailing, constant: -footerInsets.right),
        ])
    }
}

// MARK: - Manage header view
private extension ScrollViewController {
    func removeHeaderView(_ headerView: UIView) {
        headerView.removeFromSuperview()
        updateHeaderViewConstraints()
    }

    func addHeaderView(_ headerView: UIView) {
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        updateHeaderViewConstraints()
    }
}

// MARK: - Manage footer view
private extension ScrollViewController {
    func removeFooterView(_ footerView: UIView) {
        footerView.removeFromSuperview()
        updateFooterViewConstraints()
        if let keyboardOffset = currentKeyboardOffset {
            updateScrollInsets(byKeyboardOffset: keyboardOffset)
        }
    }

    func addFooterView(_ footerView: UIView) {
        view.addSubview(footerView)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        updateFooterViewConstraints()
        if currentKeyboardOffset != nil {
            removeScrollInsetsForKeyboard()
        }
    }
}
