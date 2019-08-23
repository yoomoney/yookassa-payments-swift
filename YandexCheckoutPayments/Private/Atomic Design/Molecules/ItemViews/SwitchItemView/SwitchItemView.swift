import FunctionalSwift
import UIKit

final class SwitchItemView: UIView {

    // MARK: - Public accessors
    var title: String {
        set {
            titleLabel.styledText = newValue
        }
        get {
            return titleLabel.styledText ?? ""
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
    weak var delegate: SwitchItemViewOutput?

    // MARK: - UI properties
    private(set) lazy var titleLabel: UILabel = {
        return $0
    }(UILabel())

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
            titleLabel,
            switchControl,
        ]
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        addSubview <^> subviews
    }

    private func setupConstraints() {
        NSLayoutConstraint.deactivate(activeConstraints)
        if UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory {
            activeConstraints = [
                titleLabel.leading.constraint(equalTo: leadingMargin),
                titleLabel.top.constraint(equalTo: topMargin),
                titleLabel.trailing.constraint(equalTo: trailingMargin),

                switchControl.leading.constraint(equalTo: leadingMargin),
                switchControl.trailing.constraint(equalTo: trailingMargin),
                switchControl.bottom.constraint(equalTo: bottomMargin),
                switchControl.top.constraint(equalTo: titleLabel.bottom,
                                             constant: Space.double),
            ]
        } else {
            let switchControlBottomConstraint = switchControl.bottom.constraint(lessThanOrEqualTo: bottomMargin)
            switchControlBottomConstraint.priority = .defaultHigh
            let titleLabelTopConstraint = titleLabel.top.constraint(equalTo: topMargin)
            titleLabelTopConstraint.priority = .defaultHigh
            activeConstraints = [
                switchControlBottomConstraint,
                switchControl.top.constraint(equalTo: topMargin),
                switchControl.trailing.constraint(equalTo: trailingMargin),
                switchControl.leading.constraint(equalTo: titleLabel.trailing,
                                                 constant: Space.double),

                titleLabelTopConstraint,
                titleLabel.leading.constraint(equalTo: leadingMargin),
                titleLabel.top.constraint(greaterThanOrEqualTo: topMargin),
                titleLabel.centerY.constraint(equalTo: centerY),
            ]
        }
        NSLayoutConstraint.activate(activeConstraints)
    }

    // MARK: - Actions
    @objc
    private func switchStateDidChange(_ sender: UISwitch) {
        delegate?.switchItemView(self, didChangeState: sender.isOn)
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
        titleLabel.applyStyles()
        switchControl.applyStyles()
        setupConstraints()
    }

    // MARK: - TintColor actions

    override func tintColorDidChange() {
        applyStyles()
    }
}

// MARK: - SwitchItemViewInput
extension SwitchItemView: SwitchItemViewInput {}

// MARK: - ListItemView
extension SwitchItemView: ListItemView {
    var leftSeparatorInset: CGFloat {
        return titleLabel.frame.minX
    }
}
