import UIKit

final class LargeIconItemView: UIView {

    // MARK: - Public accessors
    var image: UIImage {
        set {
            imageView.image = newValue
        }
        get {
            return imageView.image ?? UIImage()
        }
    }

    var actionButtonTitle: String {
        set {
            actionButton.setStyledTitle(newValue, for: .normal)
        }
        get {
            return actionButton.styledTitle(for: .normal) ?? ""
        }
    }

    var title: String {
        set {
            titleLabel.styledText = newValue
        }
        get {
            return titleLabel.styledText ?? ""
        }
    }

    // MARK: - UI properties
    private(set) lazy var imageView: UIImageView = {
        $0.setStyles(UIImageView.Styles.dynamicSize)
        return $0
    }(UIImageView())

    private(set) lazy var actionButton: UIButton = {
        $0.setStyles(UIButton.DynamicStyle.link)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.addTarget(self, action: #selector(actionButtonDidPressed), for: .touchUpInside)
        return $0
    }(UIButton())

    private(set) lazy var titleLabel: UILabel = {
        $0.setStyles(UILabel.DynamicStyle.bodySemibold,
                     UILabel.Styles.multiline)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .vertical)
        return $0
    }(UILabel())

    private lazy var labelsView: UIView = {
        $0.layoutMargins = .zero
        return $0
    }(UIView())

    // MARK: - LargeIconItemViewOutput
    weak var output: LargeIconItemViewOutput?

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
        subscribeOnNotifications()
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            actionButton,
            titleLabel,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            labelsView.addSubview($0)
        }

        [
            labelsView,
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
                labelsView.top.constraint(equalTo: topMargin),
                labelsView.bottom.constraint(equalTo: bottomMargin),
                imageView.bottom.constraint(equalTo: bottomMargin),
            ]

            highPriorityConstraints.forEach { $0.priority = .defaultHigh }

            activeConstraints = [
                imageView.top.constraint(equalTo: topMargin),
                imageView.leading.constraint(equalTo: leadingMargin),

                labelsView.trailing.constraint(equalTo: trailingMargin),
                labelsView.centerY.constraint(equalTo: centerY),
                labelsView.top.constraint(greaterThanOrEqualTo: topMargin),
                labelsView.bottom.constraint(greaterThanOrEqualTo: bottomMargin),
                labelsView.leading.constraint(equalTo: imageView.trailing,
                                              constant: Space.double),
            ]
            activeConstraints += highPriorityConstraints

        } else {
            activeConstraints = [
                imageView.top.constraint(equalTo: topMargin),
                imageView.leading.constraint(equalTo: leadingMargin),
                imageView.trailing.constraint(lessThanOrEqualTo: trailingMargin),

                labelsView.leading.constraint(equalTo: leadingMargin),
                labelsView.trailing.constraint(equalTo: trailingMargin),
                labelsView.bottom.constraint(equalTo: bottomMargin),
                labelsView.top.constraint(equalTo: imageView.bottom,
                                          constant: Space.double),
            ]
        }

        activeConstraints += [
            imageView.height.constraint(equalToConstant: Space.fivefold),
            imageView.width.constraint(equalTo: imageView.height),
        ]

        let buttonAnchorPoint = actionButton.titleLabel ?? actionButton

        activeConstraints += [
            actionButton.leading.constraint(equalTo: labelsView.leadingMargin),
            actionButton.trailing.constraint(lessThanOrEqualTo: labelsView.trailingMargin),
            buttonAnchorPoint.top.constraint(equalTo: labelsView.topMargin),
            buttonAnchorPoint.bottom.constraint(equalTo: titleLabel.top),

            titleLabel.leading.constraint(equalTo: labelsView.leadingMargin),
            titleLabel.trailing.constraint(equalTo: labelsView.trailingMargin),
            titleLabel.bottom.constraint(equalTo: labelsView.bottomMargin),
        ]

        NSLayoutConstraint.activate(activeConstraints)
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
        actionButton.setStyledTitle(actionButton.styledTitle(for: .normal), for: .normal)
        titleLabel.styledText = title
        setupConstraints()
    }

    // MARK: - Actions
    @objc
    private func actionButtonDidPressed() {
        output?.didPressActionButton(in: self)
    }
}

// MARK: - LargeItemViewInput
extension LargeIconItemView: LargeIconItemViewInput {}

// MARK: - ListItemView

extension LargeIconItemView: ListItemView {
    var leftSeparatorInset: CGFloat {
        return titleLabel.convert(titleLabel.bounds, to: self).minX
    }
}
