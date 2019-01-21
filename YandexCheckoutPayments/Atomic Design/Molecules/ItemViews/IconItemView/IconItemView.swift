import UIKit

/// Simple multiline text and icon View
final class IconItemView: UIView {

    /// Textual content
    var title: String {
        set {
            titleLabel.styledText = newValue
        }
        get {
            return titleLabel.styledText ?? ""
        }
    }

    /// Icon content
    var icon: UIImage {
        set {
            iconView.image = newValue
        }
        get {
            return iconView.image
        }
    }

    /// Badge image
    var badge: UIImage? {
        set {
            badgeImageView.image = newValue
            badgeImageView.isHidden = newValue == nil
        }
        get {
            return badgeImageView.image
        }
    }

    let titleLabel: UILabel = {
        $0.setStyles(UILabel.DynamicStyle.body,
                     UILabel.Styles.doubleLine)
        return $0
    }(UILabel())

    let iconView: IconView = {
        $0.imageView.setStyles(UIImageView.Styles.dynamicSize)
        return $0
    }(IconView())

    private(set) lazy var badgeImageView: UIImageView = {
        $0.setStyles(UIImageView.Styles.badge)
        $0.isHidden = true
        return $0
    }(UIImageView())

    private var activeConstraints: [NSLayoutConstraint] = []

    // MARK: - Initializers
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
        subscribeOnNotifications()
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        let subviews: [UIView] = [
            iconView,
            badgeImageView,
            titleLabel,
        ]
        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.deactivate(activeConstraints)
        if UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory {
            activeConstraints = [
                iconView.top.constraint(equalTo: topMargin),
                iconView.leading.constraint(equalTo: leadingMargin),
                iconView.trailing.constraint(lessThanOrEqualTo: trailingMargin),

                titleLabel.leading.constraint(equalTo: leadingMargin),
                titleLabel.trailing.constraint(equalTo: trailingMargin),
                titleLabel.bottom.constraint(equalTo: bottomMargin),
                titleLabel.top.constraint(equalTo: iconView.bottom,
                                          constant: Space.double),
            ]
        } else {
            activeConstraints = [
                iconView.top.constraint(greaterThanOrEqualTo: topMargin),
                iconView.bottom.constraint(lessThanOrEqualTo: bottomMargin),
                titleLabel.bottom.constraint(lessThanOrEqualTo: bottomMargin),
                titleLabel.top.constraint(greaterThanOrEqualTo: topMargin),

                titleLabel.centerY.constraint(equalTo: centerY),
                iconView.centerY.constraint(equalTo: centerY),

                iconView.leading.constraint(equalTo: leadingMargin),
                titleLabel.leading.constraint(equalTo: iconView.trailing,
                                              constant: Space.double),
                titleLabel.trailing.constraint(equalTo: trailingMargin),
            ]
            let lowPriorityConstraints: [NSLayoutConstraint] = [
                iconView.top.constraint(equalTo: topMargin),
                iconView.bottom.constraint(equalTo: bottomMargin),
                titleLabel.top.constraint(equalTo: topMargin),
                titleLabel.bottom.constraint(equalTo: bottomMargin),
            ]
            titleLabel.setContentHuggingPriority(.required, for: .vertical)
            titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            titleLabel.setContentHuggingPriority(.required, for: .horizontal)

            iconView.setContentHuggingPriority(.required, for: .vertical)
            iconView.setContentCompressionResistancePriority(.required, for: .vertical)
            iconView.setContentHuggingPriority(.required, for: .horizontal)
            iconView.setContentCompressionResistancePriority(.required, for: .horizontal)

            lowPriorityConstraints.forEach {
                $0.priority = .highest
            }
            activeConstraints += lowPriorityConstraints
        }

        activeConstraints += [
            iconView.width.constraint(equalTo: iconView.height),
            badgeImageView.bottom.constraint(equalTo: iconView.bottom,
                                             constant: Space.single),
            badgeImageView.trailing.constraint(equalTo: iconView.trailing,
                                               constant: Space.single),
        ]

        NSLayoutConstraint.activate(activeConstraints)
    }

    // MARK: - Accessibility
    @objc
    private func accessibilityReapply() {
        titleLabel.applyStyles()
        iconView.applyStyles()
        setupConstraints()
    }

    // MARK: - Notifications
    private func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(accessibilityReapply),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - IconItemViewInput
extension IconItemView: IconItemViewInput {}

// MARK: - ListItemView
extension IconItemView: ListItemView {
    var leftSeparatorInset: CGFloat {
        return titleLabel.frame.minX
    }
}
