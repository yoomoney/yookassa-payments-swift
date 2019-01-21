import FunctionalSwift
import UIKit

class TitledSwitchView: UIView {

    // MARK: - Public properties

    var title: String? {
        get {
            return titleLabel.styledText
        }
        set {
            titleLabel.styledText = newValue
        }
    }

    var valueChangeHandler: ((Bool) -> Void)?

    var isOn: Bool {
        get {
            return switchControl.isOn
        }
        set {
            switchControl.isOn = newValue
        }
    }

    // MARK: - UI properties

    private lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setStyles(UILabel.DynamicStyle.body, UILabel.Styles.multiline)
        return $0
    }(UILabel())

    lazy var switchControl: UISwitch = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setStyles(UISwitch.Styles.mustardOnTintColor)
        $0.addTarget(self, action: #selector(onSwitchValueChange(_:)), for: .valueChanged)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
    }(UISwitch())

    private var titleLabelTrailingConstraint: NSLayoutConstraint?

    // MARK: - Initialization/Deinitialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        subscribeToNotifications()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) is not implemented")
    }

    private func setupUI() {
        addSubview <^> [titleLabel, switchControl]

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.deactivate(currentConstraints)

        if UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory {
            let trailingConstraint = trailing.constraint(equalTo: titleLabel.trailing,
                                                         constant: trailingMarginValue())
            titleLabelTrailingConstraint = trailingConstraint

            currentConstraints = [
                titleLabel.top.constraint(equalTo: topMargin, constant: Space.single),
                titleLabel.leading.constraint(equalTo: leadingMargin),
                trailingConstraint,
                switchControl.top.constraint(equalTo: titleLabel.bottom, constant: Space.single),
                switchControl.leading.constraint(equalTo: leadingMargin),
                bottomMargin.constraint(equalTo: switchControl.bottom, constant: Space.single),
            ]
        } else {
            currentConstraints = [
                titleLabel.top.constraint(equalTo: topMargin, constant: Space.single),
                titleLabel.leading.constraint(equalTo: leadingMargin),
                bottomMargin.constraint(equalTo: titleLabel.bottom, constant: Space.single),
                switchControl.leading.constraint(equalTo: titleLabel.trailing, constant: Space.double),
                switchControl.centerY.constraint(equalTo: centerY),
                trailingMargin.constraint(equalTo: switchControl.trailing),
            ]
        }

        NSLayoutConstraint.activate(currentConstraints)
    }

    deinit {
        cancelNotificationsSubscriptions()
    }

    // MARK: - Private properties

    private var currentConstraints: [NSLayoutConstraint] = []

    // MARK: - Configuring Content Margins

    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()

        titleLabelTrailingConstraint?.constant = trailingMarginValue()
    }

    private func trailingMarginValue() -> CGFloat {
        if #available(iOS 11.0, *) {
            return directionalLayoutMargins.trailing
        } else {
            return layoutMargins.right
        }
    }

    // MARK: - Notifications

    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onUIContentSizeCategoryDidChange),
                                               name: .UIContentSizeCategoryDidChange,
                                               object: nil)
    }

    private func cancelNotificationsSubscriptions() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIContentSizeCategoryDidChange,
                                                  object: nil)
    }

    @objc
    private func onUIContentSizeCategoryDidChange() {
        titleLabel.styledText = title
        setupConstraints()
    }

    @objc
    private func onSwitchValueChange(_ sender: UISwitch) {
        valueChangeHandler?(sender.isOn)
    }

}

// MARK: - TableViewCellDataProviderSupport

extension TitledSwitchView: TableViewCellDataProviderSupport {

    class var estimatedCellHeight: CGFloat {
        return 56.0
    }

}
