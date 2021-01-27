import UIKit

class IconButtonItemView: UIView {
    var title: String {
        set {
            titleLabel.styledText = newValue
        }
        get {
            return titleLabel.styledText ?? ""
        }
    }

    var image: UIImage? {
        set {
            guard newValue !== imageView.image else { return }
            labelToViewOrImageConstraint.isActive = false
            imageView.image = newValue
            setNeedsUpdateConstraints()
        }
        get {
            return imageView.image
        }
    }

    var buttonTitle: String? {
        willSet {
            guard buttonTitle != newValue else { return }
            labelToViewOrButtonConstraint.isActive = false
            setNeedsUpdateConstraints()
        }
        didSet {
            button.setStyledTitle(buttonTitle, for: .normal)
        }
    }

    /// IconButtonItemViewOutput
    weak var output: IconButtonItemViewOutput?

    // MARK: - UI properties

    lazy var titleLabel: UILabel = {
        $0.setStyles(UILabel.DynamicStyle.bodySemibold, UILabel.Styles.multiline)
        $0.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        $0.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        return $0
    }(UILabel())

    lazy var imageView: UIImageView = {
        $0.setStyles(UIImageView.Styles.dynamicSize)
        return $0
    }(UIImageView())

    lazy var button: UIButton = {
        $0.setStyles(UIButton.DynamicStyle.link)
        $0.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        $0.addTarget(self, action: #selector(actionButtonDidPressed), for: .touchUpInside)
        return $0
    }(UIButton(type: .custom))

    // MARK: - Constraints properties

    private lazy var leadingLabelToMarginConstraint: NSLayoutConstraint = {
        self.titleLabel.leading.constraint(equalTo: self.leadingMargin)
    }()

    private lazy var leadingLabelToImageConstraint: NSLayoutConstraint = {
        self.titleLabel.leading.constraint(equalTo: self.imageView.trailing,
                                           constant: Space.double)
    }()

    private lazy var topLabelToMarginConstraint: NSLayoutConstraint = {
        self.titleLabel.top.constraint(equalTo: self.topMargin)
    }()

    private lazy var topLabelToImageConstraint: NSLayoutConstraint = {
        self.titleLabel.top.constraint(equalTo: self.imageView.bottom,
                                       constant: Space.double)
    }()

    private lazy var trailingLabelToMarginConstraint: NSLayoutConstraint = {
        self.titleLabel.trailing.constraint(equalTo: self.trailingMargin)
    }()

    private lazy var trailingLabelToButtonConstraint: NSLayoutConstraint = {
        self.button.leading.constraint(greaterThanOrEqualTo: self.titleLabel.trailing,
                                       constant: Space.double)
    }()

    private lazy var bottomLabelToMarginConstraint: NSLayoutConstraint = {
        self.titleLabel.bottom.constraint(equalTo: self.bottomMargin)
    }()

    private lazy var bottomLabelToButtonConstraint: NSLayoutConstraint = {
        self.button.top.constraint(equalTo: self.titleLabel.bottom,
                                   constant: Space.double)
    }()

    var labelToViewOrImageConstraint: NSLayoutConstraint {
        let constraint: NSLayoutConstraint
        let isAccessibilitySizeCategory = UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory

        switch (imageView.image, isAccessibilitySizeCategory) {
        case (.none, false):
            constraint = leadingLabelToMarginConstraint
        case (.some, false):
            constraint = leadingLabelToImageConstraint
        case (.none, true):
            constraint = topLabelToMarginConstraint
        case (.some, true):
            constraint = topLabelToImageConstraint
        }

        return constraint
    }

    var labelToViewOrButtonConstraint: NSLayoutConstraint {
        let constraint: NSLayoutConstraint
        let isAccessibilitySizeCategory = UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory

        switch (buttonTitle, isAccessibilitySizeCategory) {
        case (.none, false):
            constraint = trailingLabelToMarginConstraint
        case (.some, false):
            constraint = trailingLabelToButtonConstraint
        case (.none, true):
            constraint = bottomLabelToMarginConstraint
        case (.some, true):
            constraint = bottomLabelToButtonConstraint
        }

        return constraint
    }

    private var activeConstraints: [NSLayoutConstraint] = []

    // MARK: - Initializers & deinitializer
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
        [
            titleLabel,
            imageView,
            button,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    private func setupConstraints() {
        if activeConstraints.isEmpty == false {
            NSLayoutConstraint.deactivate(activeConstraints)
        }

        let isAccessibilitySizeCategory = UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory

        // View for vertical alignment button. Button frame is more than label in button.
        let buttonVertical: UIView = button.titleLabel ?? button

        if isAccessibilitySizeCategory == false {
            activeConstraints = [
                imageView.leading.constraint(equalTo: leadingMargin),
                imageView.top.constraint(equalTo: topMargin),
                imageView.bottom.constraint(equalTo: bottomMargin),
                titleLabel.top.constraint(greaterThanOrEqualTo: topMargin,
                                          constant: Space.single),
                // TODO: Fix label position (BIOS-19)
                titleLabel.centerY.constraint(equalTo: centerY),
                buttonVertical.top.constraint(greaterThanOrEqualTo: topMargin,
                                              constant: Space.single),
                bottomMargin.constraint(greaterThanOrEqualTo: buttonVertical.bottom,
                                              constant: Space.single),
                button.trailing.constraint(equalTo: trailingMargin),
            ]
        } else {
            activeConstraints = [
                imageView.leading.constraint(equalTo: leadingMargin),
                imageView.top.constraint(equalTo: topMargin),
                imageView.trailing.constraint(lessThanOrEqualTo: trailingMargin),
                titleLabel.leading.constraint(equalTo: leadingMargin),
                titleLabel.trailing.constraint(equalTo: trailingMargin),
                button.leading.constraint(equalTo: leadingMargin),
                button.trailing.constraint(lessThanOrEqualTo: trailingMargin),
                buttonVertical.bottom.constraint(equalTo: bottomMargin),
            ]
        }

        activeConstraints += [
            imageView.width.constraint(equalTo: imageView.height),
        ]

        activeConstraints += [
            labelToViewOrImageConstraint,
            labelToViewOrButtonConstraint,
        ]

        NSLayoutConstraint.activate(activeConstraints)
    }

    // MARK: - Accessibility

    @objc
    private func accessibilityReapply() {
        titleLabel.styledText = title
        button.setStyledTitle(button.styledTitle(for: .normal), for: .normal)
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

    // MARK: - Triggering Auto Layout

    override func updateConstraints() {
        let constraints = [
            labelToViewOrImageConstraint,
            labelToViewOrButtonConstraint,
        ]

        constraints.forEach {
            if $0.isActive == false {
                activeConstraints.append($0)
                $0.isActive = true
            }
        }

        super.updateConstraints()
    }

    // MARK: - Actions
    @objc
    private func actionButtonDidPressed() {
        output?.didPressButton(in: self)
    }
}

// MARK: - IconButtonItemViewInput
extension IconButtonItemView: IconButtonItemViewInput {}

// MARK: - ListItemView
extension IconButtonItemView: ListItemView {
    var leftSeparatorInset: CGFloat {
        return titleLabel.frame.minX
    }
}
