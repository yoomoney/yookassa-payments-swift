import UIKit

final class ActionSheetHeaderView: UIView {
    var title: String {
        set {
            titleLabel.styledText = newValue
        }
        get {
            return titleLabel.styledText ?? ""
        }
    }

    var logo: UIImage? {
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

    // MARK: - UI properties

    private lazy var titleLabel: UILabel = {
        $0.setStyles(UILabel.DynamicStyle.headline2, UILabel.Styles.multiline)
        return $0
    }(UILabel())

    private lazy var imageView: UIImageView = {
        if #available(iOS 11.0, *) {
            $0.adjustsImageSizeForAccessibilityContentSizeCategory = true
        }
        $0.contentMode = .scaleAspectFit
        $0.setContentHuggingPriority(.required, for: .horizontal)
        return $0
    }(UIImageView())

    // MARK: - Constraints properties

    private lazy var trailingLabelToMarginConstraint: NSLayoutConstraint = {
        self.titleLabel.trailing.constraint(equalTo: self.trailingMargin)
    }()

    private lazy var trailingLabelToImageConstraint: NSLayoutConstraint = {
        self.imageView.leading.constraint(equalTo: self.titleLabel.trailing,
                                          constant: Space.single)
    }()

    private lazy var bottomLabelToMarginConstraint: NSLayoutConstraint = {
        self.titleLabel.bottom.constraint(equalTo: self.bottomMargin)
    }()

    private lazy var bottomLabelToImageConstraint: NSLayoutConstraint = {
        self.imageView.top.constraint(equalTo: self.titleLabel.bottom,
                                      constant: Space.single)
    }()

    private var labelToViewOrImageConstraint: NSLayoutConstraint {
        let constraint: NSLayoutConstraint
        let isAccessibilitySizeCategory = UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory

        switch (imageView.image, isAccessibilitySizeCategory) {
        case (.none, false):
            constraint = trailingLabelToMarginConstraint
        case (.some, false):
            constraint = trailingLabelToImageConstraint
        case (.none, true):
            constraint = bottomLabelToMarginConstraint
        case (.some, true):
            constraint = bottomLabelToImageConstraint
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
        layoutMargins = UIEdgeInsets(top: Space.double,
                                     left: Space.double,
                                     bottom: Space.single,
                                     right: Space.double)
        backgroundColor = .clear
        subscribeOnNotifications()
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            titleLabel,
            imageView,
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

        if isAccessibilitySizeCategory == false {
            let highPriorityConstraints = [
                titleLabel.top.constraint(equalTo: topMargin),
                titleLabel.bottom.constraint(equalTo: bottomMargin),
                imageView.top.constraint(equalTo: topMargin),
                imageView.bottom.constraint(equalTo: bottomMargin),
            ]

            highPriorityConstraints.forEach {
                $0.priority = .defaultHigh
            }

            activeConstraints = [
                titleLabel.leading.constraint(equalTo: leadingMargin),
                imageView.trailing.constraint(equalTo: trailingMargin),
                titleLabel.top.constraint(greaterThanOrEqualTo: topMargin),
                titleLabel.bottom.constraint(greaterThanOrEqualTo: bottomMargin),
                imageView.top.constraint(greaterThanOrEqualTo: topMargin),
                imageView.bottom.constraint(greaterThanOrEqualTo: bottomMargin),
            ] + highPriorityConstraints

        } else {
            activeConstraints = [
                titleLabel.leading.constraint(equalTo: leadingMargin),
                titleLabel.trailing.constraint(equalTo: trailingMargin),
                titleLabel.top.constraint(equalTo: topMargin),
                imageView.leading.constraint(equalTo: leadingMargin),
                imageView.trailing.constraint(lessThanOrEqualTo: trailingMargin),
                imageView.bottom.constraint(equalTo: bottomMargin),
            ]
        }

        activeConstraints.append(labelToViewOrImageConstraint)

        NSLayoutConstraint.activate(activeConstraints)
    }

    // MARK: - Accessibility

    @objc
    private func accessibilityReapply() {
        titleLabel.styledText = title
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
        let constraint = labelToViewOrImageConstraint

        if constraint.isActive == false {
            activeConstraints.append(constraint)
            constraint.isActive = true
        }

        super.updateConstraints()
    }
}
