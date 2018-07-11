import FunctionalSwift
import UIKit

class TextValueView: UIView {

    // MARK: - Public properties

    var title: String? {
        get {
            return titleLabel.styledText
        }
        set {
            titleLabel.styledText = newValue
        }
    }

    var value: String? {
        get {
            return valueLabel.styledText
        }
        set {
            valueLabel.styledText = newValue
        }
    }

    // MARK: - UI properties

    private lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setStyles(UILabel.DynamicStyle.body, UILabel.Styles.multiline)
        return $0
    }(UILabel())

    private lazy var valueLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setStyles(UILabel.DynamicStyle.body, UILabel.ColorStyle.secondary, UILabel.Styles.multiline)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        return $0
    }(UILabel())

    // MARK: - Private properties

    private var currentConstraints: [NSLayoutConstraint] = []

    // MARK: - Initialization/Deinitialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()

        subscribeToNotifications()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) is not implemented")
    }

    deinit {
        cancelNotificationsSubscriptions()
    }

    // MARK: - Private methods

    private func setupUI() {
        addSubview <^> [titleLabel, valueLabel]

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.deactivate(currentConstraints)

        if UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory {
            currentConstraints = [
                titleLabel.top.constraint(equalTo: topMargin, constant: Space.single),
                titleLabel.leading.constraint(equalTo: leadingMargin),
                trailingMargin.constraint(equalTo: titleLabel.trailing),
                valueLabel.top.constraint(equalTo: titleLabel.bottom, constant: Space.single),
                valueLabel.leading.constraint(equalTo: leadingMargin),
                trailingMargin.constraint(equalTo: valueLabel.trailing),
                bottomMargin.constraint(equalTo: valueLabel.bottom, constant: Space.single),
            ]
        } else {
            currentConstraints = [
                titleLabel.top.constraint(equalTo: topMargin, constant: Space.single),
                titleLabel.leading.constraint(equalTo: leadingMargin),
                bottomMargin.constraint(equalTo: titleLabel.bottom, constant: Space.single),
                valueLabel.top.constraint(greaterThanOrEqualTo: topMargin, constant: Space.single),
                valueLabel.leading.constraint(equalTo: titleLabel.trailing, constant: Space.double),
                bottomMargin.constraint(greaterThanOrEqualTo: valueLabel.bottom, constant: Space.single),
                valueLabel.centerY.constraint(equalTo: titleLabel.centerY),
                trailingMargin.constraint(equalTo: valueLabel.trailing),
            ]
        }

        NSLayoutConstraint.activate(currentConstraints)
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
        valueLabel.styledText = value
        setupConstraints()
    }
}

// MARK: - TableViewCellDataProviderSupport

extension TextValueView: TableViewCellDataProviderSupport {

    class var estimatedCellHeight: CGFloat {
        return 56.0
    }

}
