import FunctionalSwift
import UIKit

final class LinkedSwitchItemView: UIView {

    // MARK: - Public accessors

    var attributedString: NSAttributedString {
        get {
            return linkedTextView.attributedText
        }
        set {
            linkedTextView.attributedText = newValue
        }
    }

    var state: Bool {
        set {
            switchControl.setOn(newValue, animated: true)
        }
        get {
            return switchControl.isOn
        }
    }

    // MARK: - SwitchItemViewOutput

    weak var delegate: LinkedSwitchItemViewOutput?

    // MARK: - UI properties

    private(set) lazy var linkedTextView: LinkedTextView = {
        let view = LinkedTextView()
        view.setStyles(UIView.Styles.grayBackground,
                       UITextView.Styles.linked)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private(set) lazy var switchControl: UISwitch = {
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.addTarget(self, action: #selector(switchStateDidChange), for: .valueChanged)
        return $0
    }(UISwitch())

    // MARK: - Constraints

    private var activeConstraints: [NSLayoutConstraint] = []

    // MARK: - Creating a View Object, deinitializer.

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    deinit {
        unsubscribeFromNotifications()
    }

    // MARK: - Setup view
    private func setupView() {
        backgroundColor = .clear
        layoutMargins = UIEdgeInsets(top: Space.double,
                                     left: Space.double,
                                     bottom: Space.double,
                                     right: Space.double)
        setStyles(Styles.primary)
        subscribeOnNotifications()
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        let subviews: [UIView] = [
            linkedTextView,
            switchControl,
        ]
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        addSubview <^> subviews
    }

    private func setupConstraints() {
        NSLayoutConstraint.deactivate(activeConstraints)
        if UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory {
            activeConstraints = [
                linkedTextView.leading.constraint(equalTo: leadingMargin),
                linkedTextView.top.constraint(equalTo: topMargin),
                linkedTextView.trailing.constraint(equalTo: trailingMargin),

                switchControl.leading.constraint(equalTo: leadingMargin),
                switchControl.trailing.constraint(equalTo: trailingMargin),
                switchControl.bottom.constraint(equalTo: bottomMargin),
                switchControl.top.constraint(equalTo: linkedTextView.bottom,
                                             constant: Space.double),
            ]
        } else {
            let switchControlBottomConstraint = switchControl.bottom.constraint(lessThanOrEqualTo: bottomMargin)
            switchControlBottomConstraint.priority = .defaultHigh
            let linkedTextViewTopConstraint = linkedTextView.top.constraint(equalTo: topMargin)
            linkedTextViewTopConstraint.priority = .defaultHigh
            activeConstraints = [
                switchControlBottomConstraint,
                switchControl.top.constraint(equalTo: topMargin),
                switchControl.trailing.constraint(equalTo: trailingMargin),
                switchControl.leading.constraint(equalTo: linkedTextView.trailing,
                                                 constant: Space.double),

                linkedTextViewTopConstraint,
                linkedTextView.leading.constraint(equalTo: leadingMargin),
                linkedTextView.top.constraint(greaterThanOrEqualTo: topMargin),
                linkedTextView.centerY.constraint(equalTo: centerY),
            ]
        }
        NSLayoutConstraint.activate(activeConstraints)
    }

    // MARK: - Actions

    @objc
    private func switchStateDidChange(_ sender: UISwitch) {
        delegate?.linkedSwitchItemView(self, didChangeState: sender.isOn)
    }

    // MARK: - Notifications

    private func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contentSizeCategoryDidChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func contentSizeCategoryDidChange() {
        linkedTextView.applyStyles()
        switchControl.applyStyles()
        setupConstraints()
    }

    // MARK: - TintColor actions

    override func tintColorDidChange() {
        applyStyles()
    }
}

// MARK: - SwitchItemViewInput

extension LinkedSwitchItemView: LinkedSwitchItemViewInput {}

// MARK: - ListItemView

extension LinkedSwitchItemView: ListItemView {
    var leftSeparatorInset: CGFloat {
        return linkedTextView.frame.minX
    }
}

// MARK: - UITextViewDelegate

extension LinkedSwitchItemView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange
    ) -> Bool {
        delegate?.didTapOnLinkedView(on: self)
        return false
    }
}
