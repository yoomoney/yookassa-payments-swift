import UIKit

final class LargeActionInformer: UIView {
    // MARK: - UI properties

    private(set) lazy var iconView: IconView = {
        let iconView = IconView()
        iconView.imageView.accessibilityIdentifier = "informer.icon.image.view"
        return iconView
    }()

    private(set) lazy var actionTemplate: ActionTemplate = {
        let actionTemplate = ActionTemplate()
        actionTemplate.translatesAutoresizingMaskIntoConstraints = false
        actionTemplate.addTarget(self, action: #selector(actionTemplateDidPress), for: .touchUpInside)
        actionTemplate.contentView = self.buttonLabel
        return actionTemplate
    }()

    private(set) lazy var buttonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.accessibilityIdentifier = "informer.action.label"
        return label
    }()

    // Set values to display. Defaults `nil` for each param.
    func set(icon: UIImage? = nil, message: String? = nil, actionTitle: String? = nil) {
        iconView.image = icon ?? PaymentMethodResources.Image.unknown
        messageLabel.styledText = message
        buttonLabel.styledText = actionTitle
    }

    private(set) lazy var messageLabel = UILabel()

    var actionHandler: (() -> Void)?

    // MARK: - Constraints

    private var activeConstraints: [NSLayoutConstraint] = []

    // MARK: - Initializers

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    deinit {
        unsubscribeFromNotifications()
    }

    // MARK: - Setup view

    private func setupView() {
        layer.cornerRadius = Space.single
        layoutMargins = UIEdgeInsets(top: Space.double, left: Space.double, bottom: Space.double, right: Space.double)
        Style.default(self)
        setupSubviews()
        setupConstraints()
        subscribeOnNotifications()
    }

    private func setupSubviews() {
        let subviews: [UIView] = [
            iconView,
            messageLabel,
            actionTemplate,
        ]
        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentHuggingPriority(.required, for: .horizontal)
            addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.deactivate(activeConstraints)
        if UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory {
            activeConstraints = [
                iconView.top.constraint(equalTo: topMargin),
                iconView.leading.constraint(equalTo: leadingMargin),
                iconView.trailing.constraint(lessThanOrEqualTo: trailingMargin),

                messageLabel.leading.constraint(equalTo: leadingMargin),
                messageLabel.trailing.constraint(equalTo: trailingMargin),
                messageLabel.top.constraint(equalTo: iconView.bottom, constant: Space.double),

                actionTemplate.top.constraint(equalTo: messageLabel.bottom, constant: Space.double),
                actionTemplate.trailing.constraint(equalTo: trailingMargin),
                actionTemplate.leading.constraint(greaterThanOrEqualTo: leadingMargin),
                actionTemplate.bottom.constraint(equalTo: bottomMargin),
            ]
        } else {
            let buttonBottomConstraint = actionTemplate.bottom.constraint(equalTo: bottomMargin)
            let iconViewBottomConstraint = iconView.bottom.constraint(equalTo: bottomMargin)

            let additionalConstraints: [NSLayoutConstraint] = [
                buttonBottomConstraint,
                iconViewBottomConstraint,
            ]
            additionalConstraints.forEach {
                $0.priority = .defaultHigh
            }
            activeConstraints = [
                iconView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                iconView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                iconView.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor),

                messageLabel.topAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.topAnchor),
                messageLabel.leading.constraint(equalTo: iconView.trailing, constant: Space.double),
                messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),

                actionTemplate.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Space.single),
                actionTemplate.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
                actionTemplate.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
                actionTemplate.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            ]
            activeConstraints += additionalConstraints
        }
        NSLayoutConstraint.activate(activeConstraints)
    }

    // MARK: - Drawing and Updating the View

    public override func tintColorDidChange() {
        super.tintColorDidChange()
        buttonLabel.tintColor = tintColor
        buttonLabel.applyStyles()
    }

    // MARK: - Notifications

    private func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func contentSizeCategoryDidChange() {
        iconView.applyStyles()
        messageLabel.applyStyles()
        buttonLabel.applyStyles()
        setupConstraints()
    }

    // MARK: - Actions

    @objc
    private func actionTemplateDidPress() {
        actionHandler?()
    }
}

// MARK: - Decorator

extension LargeActionInformer {
    struct Style {
        private let target: LargeActionInformer
        // Decorate target with default setup
        @discardableResult
        static func `default`(_ target: LargeActionInformer) -> Style {
            Style(target: target)
        }

        private init(target: LargeActionInformer) {
            self.target = target
            self.default()
        }

        @discardableResult
        private func `default`() -> Style {
            target.iconView.setStyles(IconView.Styles.Tint.normal)
            target.backgroundColor = .ghost
            target.buttonLabel.setStyles(UILabel.DynamicStyle.bodySemibold, UILabel.ColorStyle.Link.normal)
            target.messageLabel.setStyles(
                UILabel.ColorStyle.secondary,
                UILabel.DynamicStyle.body,
                UILabel.Styles.multiline
            )
            return self
        }

        @discardableResult
        func lamp() -> Style {
            target.backgroundColor = .mousegrey
            return self
        }

        @discardableResult
        func alert() -> Style {
            target.iconView.image = UIImage.named("ic_attention_m").colorizedImage(color: .redOrange)
            target.buttonLabel.setStyles(UILabel.ColorStyle.Link.disabled)
            return self
        }

        @discardableResult
        func disabled() -> Style {
            target.buttonLabel.appendStyle(UILabel.ColorStyle.Link.disabled)
            return self
        }
    }
}
