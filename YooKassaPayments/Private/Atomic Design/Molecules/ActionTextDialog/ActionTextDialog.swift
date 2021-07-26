import UIKit

protocol ActionTextDialogDelegate: AnyObject {
    func didPressButton()
}

/// ActionTextDialog used for PlaceholderView as contentView
final class ActionTextDialog: UIView {

    weak var delegate: ActionTextDialogDelegate?

    /// Icon content
    var icon: UIImage {
        get {
            return iconView.image ?? UIImage()
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

    /// Title for button
    var buttonTitle: String {
        set {
            button.setStyledTitle(newValue, for: .normal)
        }
        get {
            return button.styledTitle(for: .normal) ?? ""
        }
    }

    private(set) lazy var spaceBetweenTitleAndButton = button.top.constraint(equalTo: titleLabel.bottom,
                                                                             constant: Space.double)

    // MARK: - TintColor actions

    override func tintColorDidChange() {
        applyStyles()
    }

    // MARK: - UI properties

    /// Image view, no image by default.
    private(set) lazy var iconView: UIImageView = {
        $0.setStyles(UIImageView.Styles.dynamicSize)
        return $0
    }(UIImageView())

    private(set) lazy var titleLabel = UILabel()

    private(set) lazy var button: UIButton = {
        $0.addTarget(self, action: #selector(buttonDidPress), for: .touchUpInside)
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
        layoutMargins = UIEdgeInsets(top: Space.double,
                                     left: Space.triple,
                                     bottom: 0,
                                     right: Space.triple)
        setupSubviews()
        setupConstraints()
        subscribeOnNotifications()
    }

    private func setupSubviews() {
        [
            iconView,
            titleLabel,
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
            iconView.width.constraint(equalTo: iconView.height),

            titleLabel.leading.constraint(equalTo: leadingMargin),
            titleLabel.trailing.constraint(equalTo: trailingMargin),
            titleLabel.top.constraint(equalTo: iconView.bottom,
                                      constant: Space.double),

            button.leading.constraint(greaterThanOrEqualTo: leadingMargin),
            button.centerX.constraint(equalTo: centerX),
            spaceBetweenTitleAndButton,
            button.bottom.constraint(equalTo: bottomMargin),
        ]

        NSLayoutConstraint.activate(constraints)
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
        iconView.applyStyles()
        titleLabel.applyStyles()
        button.applyStyles()
    }

    @objc
    private func buttonDidPress() {
        delegate?.didPressButton()
    }

}
