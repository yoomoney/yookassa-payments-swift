import UIKit

final class OrderView: UIView {

    // MARK: - Public accessors

    var title: String {
        set {
            titleLabel.styledText = newValue
        }
        get {
            return titleLabel.styledText ?? ""
        }
    }

    var subtitle: String? {
        set {
            subtitleLabel.styledText = newValue
            subtitleLabel.isHidden = newValue == nil
            spaceBetweenTitleAndSubtitleConstraint.constant = newValue == nil ? 4 : 2
            spaceBetweenSubtitleAndValueConstraint.constant = newValue == nil ? 0 : 8
        }
        get {
            return subtitleLabel.styledText
        }
    }

    var value: String {
        set {
            valueLabel.styledText = newValue
        }
        get {
            return valueLabel.styledText ?? ""
        }
    }

    var subvalue: String? {
        set {
            subvalueLabel.styledText = newValue
            subvalueLabel.isHidden = newValue == nil
            spaceBetweenValueAndSubvalueConstraint.constant = newValue == nil ? 0 : 2
        }
        get {
            return subvalueLabel.styledText
        }
    }

    // MARK: - UI properties

    private(set) lazy var contentStackView: UIStackView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.axis = .vertical
        return $0
    }(UIStackView())

    private(set) lazy var titleLabel: UILabel = {
        $0.setStyles(
            UILabel.DynamicStyle.title3,
            UILabel.ColorStyle.primary,
            UILabel.Styles.multiline
        )
        return $0
    }(UILabel())

    private(set) lazy var subtitleLabel: UILabel = {
        $0.setStyles(
            UILabel.DynamicStyle.body,
            UILabel.ColorStyle.secondary,
            UILabel.Styles.multiline
        )
        return $0
    }(UILabel())

    private(set) lazy var valueLabel: UILabel = {
        $0.setStyles(
            UILabel.DynamicStyle.title2,
            UILabel.ColorStyle.primary,
            UILabel.Styles.multiline
        )
        return $0
    }(UILabel())

    private(set) lazy var subvalueLabel: UILabel = {
        $0.setStyles(
            UILabel.DynamicStyle.body,
            UILabel.ColorStyle.secondary,
            UILabel.Styles.multiline
        )
        return $0
    }(UILabel())

    // MARK: - Spaces

    private(set) lazy var spaceBetweenTitleAndSubtitleView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    private(set) lazy var spaceBetweenSubtitleAndValueView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    private(set) lazy var spaceBetweenValueAndSubvalueView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    // MARK: - Constraints

    private lazy var spaceBetweenTitleAndSubtitleConstraint: NSLayoutConstraint = {
        return $0
    }(spaceBetweenTitleAndSubtitleView.heightAnchor.constraint(equalToConstant: 0))

    private lazy var spaceBetweenSubtitleAndValueConstraint: NSLayoutConstraint = {
        return $0
    }(spaceBetweenSubtitleAndValueView.heightAnchor.constraint(equalToConstant: 0))

    private lazy var spaceBetweenValueAndSubvalueConstraint: NSLayoutConstraint = {
        return $0
    }(spaceBetweenValueAndSubvalueView.heightAnchor.constraint(equalToConstant: 0))

    // MARK: - Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .clear
        layoutMargins = UIEdgeInsets(
            top: Space.double,
            left: Space.double,
            bottom: Space.double,
            right: Space.double
        )
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            contentStackView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        [
            titleLabel,
            spaceBetweenTitleAndSubtitleView,
            subtitleLabel,
            spaceBetweenSubtitleAndValueView,
            valueLabel,
            spaceBetweenValueAndSubvalueView,
            subvalueLabel,
        ].forEach(contentStackView.addArrangedSubview)
    }

    private func setupConstraints() {

        let constraints = [
            spaceBetweenTitleAndSubtitleConstraint,
            spaceBetweenSubtitleAndValueConstraint,
            spaceBetweenValueAndSubvalueConstraint,

            contentStackView.top.constraint(equalTo: topMargin),
            contentStackView.bottom.constraint(equalTo: bottomMargin),
            contentStackView.leading.constraint(equalTo: leadingMargin),
            contentStackView.trailing.constraint(equalTo: trailingMargin),
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
