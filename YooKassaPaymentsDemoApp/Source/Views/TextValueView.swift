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
        [
            titleLabel,
            valueLabel,
        ].forEach(addSubview)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.deactivate(currentConstraints)

        if UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory {
            currentConstraints = [
                titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: Space.single),
                titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                layoutMarginsGuide.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Space.single),
                valueLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                layoutMarginsGuide.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
                layoutMarginsGuide.bottomAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: Space.single),
            ]
        } else {
            currentConstraints = [
                titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: Space.single),
                titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                layoutMarginsGuide.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Space.single),
                valueLabel.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor,
                                                constant: Space.single),
                valueLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Space.double),
                layoutMarginsGuide.bottomAnchor.constraint(greaterThanOrEqualTo: valueLabel.bottomAnchor,
                                                           constant: Space.single),
                valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
                layoutMarginsGuide.trailingAnchor.constraint(equalTo: valueLabel.trailingAnchor),
            ]
        }

        NSLayoutConstraint.activate(currentConstraints)
    }

    // MARK: - Notifications

    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onUIContentSizeCategoryDidChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    private func cancelNotificationsSubscriptions() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIContentSizeCategory.didChangeNotification,
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
