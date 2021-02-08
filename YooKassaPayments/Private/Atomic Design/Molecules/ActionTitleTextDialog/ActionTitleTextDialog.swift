import UIKit

protocol ActionTitleTextDialogDelegate: class {
    func didPressButton(
        in actionTitleTextDialog: ActionTitleTextDialog
    )
}

/// ActionTitleTextDialog used for PlaceholderView as contentView
final class ActionTitleTextDialog: UIView {

    weak var delegate: ActionTitleTextDialogDelegate?

    /// Icon content
    var icon: UIImage {
        get {
            return iconView.image
        }
        set {
            iconView.image = newValue
        }
    }

    /// Textual content (title)
    var title: String {
        get {
            return titleLabel.styledText ?? ""
        }
        set {
            titleLabel.styledText = newValue
        }
    }

    /// Textual content (subtitle)
    var text: String {
        get {
            return textLabel.styledText ?? ""
        }
        set {
            textLabel.styledText = newValue
        }
    }

    /// Title for button
    var buttonTitle: String {
        set {
            button.setStyledTitle(newValue, for: .normal)
        }
        get {
            return button.styledTitle(for: .normal) ?? ""
        }
    }

    override var accessibilityIdentifier: String? {
        didSet {
            guard let accessibilityIdentifier = accessibilityIdentifier else {
                iconView.accessibilityIdentifier = nil
                titleLabel.accessibilityIdentifier = nil
                textLabel.accessibilityIdentifier = nil
                button.accessibilityIdentifier = nil
                return
            }
            iconView.accessibilityIdentifier = accessibilityIdentifier + ".iconView"
            titleLabel.accessibilityIdentifier = accessibilityIdentifier + ".titleLabel"
            textLabel.accessibilityIdentifier = accessibilityIdentifier + ".textLabel"
            button.accessibilityIdentifier = accessibilityIdentifier + ".button"
        }
    }

    // MARK: - UI properties

    /// Image view, no image by default.
    private(set) lazy var iconView = IconView()

    private(set) lazy var titleLabel = UILabel()
    private(set) lazy var textLabel = UILabel()

    private(set) lazy var button: UIButton = {
        $0.addTarget(
            self,
            action: #selector(buttonDidPress),
            for: .touchUpInside
        )
        return $0
    }(UIButton(type: .custom))

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
        layoutMargins = UIEdgeInsets(
            top: Space.double,
            left: Space.triple,
            bottom: 0,
            right: Space.triple
        )
        setupSubviews()
        setupConstraints()
        subscribeOnNotifications()
    }

    private func setupSubviews() {
        textLabel.setContentCompressionResistancePriority(.highest, for: .vertical)
        [
            iconView,
            titleLabel,
            textLabel,
            button,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    private func setupConstraints() {

        let constraints = [
            iconView.top.constraint(equalTo: topMargin),
            iconView.centerX.constraint(equalTo: centerX),
            iconView.leading.constraint(greaterThanOrEqualTo: leadingMargin),

            titleLabel.leading.constraint(equalTo: leadingMargin),
            titleLabel.trailing.constraint(equalTo: trailingMargin),
            titleLabel.top.constraint(equalTo: iconView.bottom, constant: Space.double),

            textLabel.leading.constraint(equalTo: leadingMargin),
            textLabel.trailing.constraint(equalTo: trailingMargin),
            textLabel.top.constraint(equalTo: titleLabel.bottom, constant: Space.single),

            button.leading.constraint(greaterThanOrEqualTo: leadingMargin),
            button.centerX.constraint(equalTo: centerX),
            button.top.constraint(equalTo: textLabel.bottom, constant: Space.quadruple),
            button.bottom.constraint(equalTo: bottomMargin),
        ]

        NSLayoutConstraint.activate(constraints)
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
        titleLabel.applyStyles()
        textLabel.applyStyles()
        button.applyStyles()
    }

    @objc
    private func buttonDidPress() {
        delegate?.didPressButton(in: self)
    }
}
