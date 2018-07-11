import FunctionalSwift
import UIKit

protocol PriceViewModel {
    var currency: Character { get }
    var integerPart: String { get }
    var fractionalPart: String { get }
    var decimalSeparator: String { get }
}

final class PriceView: UIView {
    var text: String {
        set {
            textLabel.styledText = newValue
        }
        get {
            return textLabel.styledText ?? ""
        }
    }

    var price: PriceViewModel? {
        didSet {
            rebuildPriceLabel()
        }
    }

    // MARK: - UI properties

    private lazy var textLabel: UILabel = {
        $0.setStyles(UILabel.DynamicStyle.body, UILabel.Styles.multiline)
        return $0

    }(UILabel())

    private lazy var priceLabel: UILabel = {
        $0.setContentHuggingPriority(.required, for: .horizontal)
        return $0
    }(UILabel())

    // MARK: - Constraints properties

    private lazy var trailingTextToPriceConstraint: NSLayoutConstraint = {
        self.priceLabel.leading.constraint(equalTo: self.textLabel.trailing,
                                           constant: Space.single)
    }()

    private lazy var bottomTextToPriceConstraint: NSLayoutConstraint = {
        self.priceLabel.top.constraint(equalTo: self.textLabel.bottom,
                                       constant: Space.single)
    }()

    private var labelToViewOrImageConstraint: NSLayoutConstraint {
        let constraint: NSLayoutConstraint
        let isAccessibilitySizeCategory = UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory

        switch isAccessibilitySizeCategory {
        case false:
            constraint = trailingTextToPriceConstraint
        case true:
            constraint = bottomTextToPriceConstraint
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
        layoutMargins = UIEdgeInsets(top: Space.single,
                                     left: Space.double,
                                     bottom: Space.single,
                                     right: Space.single)
        backgroundColor = .clear
        subscribeOnNotifications()
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        let subviews: [UIView] = [
            textLabel,
            priceLabel,
        ]

        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        addSubview <^> subviews
    }

    private func setupConstraints() {
        if activeConstraints.isEmpty == false {
            NSLayoutConstraint.deactivate(activeConstraints)
        }

        let isAccessibilitySizeCategory = UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory

        if isAccessibilitySizeCategory == false {
            activeConstraints = [
                textLabel.leading.constraint(equalTo: leadingMargin),
                textLabel.top.constraint(equalTo: topMargin),
                textLabel.bottom.constraint(equalTo: bottomMargin),
                priceLabel.leading.constraint(equalTo: textLabel.trailing,
                                              constant: Space.single),
                priceLabel.top.constraint(equalTo: topMargin),
                priceLabel.bottom.constraint(equalTo: bottomMargin),
                trailingMargin.constraint(equalTo: priceLabel.trailing),
            ]
        } else {
            activeConstraints = [
                textLabel.leading.constraint(equalTo: leadingMargin),
                textLabel.trailing.constraint(lessThanOrEqualTo: trailingMargin),
                textLabel.top.constraint(equalTo: topMargin),
                priceLabel.top.constraint(equalTo: textLabel.bottom,
                                          constant: Space.single),
                priceLabel.leading.constraint(equalTo: leadingMargin),
                priceLabel.trailing.constraint(lessThanOrEqualTo: trailingMargin),
                priceLabel.bottom.constraint(equalTo: bottomMargin),
            ]
        }

        NSLayoutConstraint.activate(activeConstraints)

    }

    // MARK: - Accessibility

    @objc
    private func accessibilityReapply() {
        textLabel.styledText = textLabel.text
        rebuildPriceLabel()
        setupConstraints()

    }

    func rebuildPriceLabel() {
        guard let price = price else {
            priceLabel.text = nil
            return
        }

        let attributedText = NSMutableAttributedString()

        let sumAttributes: [NSAttributedStringKey: Any]
        let currencyAttributes: [NSAttributedStringKey: Any]

        if #available(iOS 9.0, *) {
            sumAttributes = [
                NSAttributedStringKey.font: UIFont.dynamicTitle2,
            ]
            currencyAttributes = [
                NSAttributedStringKey.font: UIFont.dynamicTitle2Light,
            ]

        } else {
            sumAttributes = [
                NSAttributedStringKey.font: UIFont.dynamicHeadline1,
            ]
            currencyAttributes = sumAttributes
        }

        attributedText.append(NSAttributedString(string: price.integerPart,
                                                 attributes: sumAttributes))
        attributedText.append(NSAttributedString(string: String(price.decimalSeparator),
                                                 attributes: sumAttributes))
        attributedText.append(NSAttributedString(string: price.fractionalPart,
                                                 attributes: sumAttributes))
        attributedText.append(NSAttributedString(string: String(price.currency),
                                                 attributes: currencyAttributes))
        priceLabel.attributedText = attributedText

    }

    // MARK: - Notifications

    private func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(accessibilityReapply),
                                               name: .UIContentSizeCategoryDidChange,
                                               object: nil)
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

}
