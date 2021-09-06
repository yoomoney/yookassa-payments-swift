import UIKit

protocol MaskedCardViewDelegate: AnyObject {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool
    func textFieldDidBeginEditing(_ textField: UITextField)
    func textFieldDidEndEditing(_ textField: UITextField)
}

final class MaskedCardView: UIView {

    enum CscState {
        case `default`
        case selected
        case noCVC
        case error
    }

    // MARK: - Delegates

    weak var delegate: MaskedCardViewDelegate?

    // MARK: - Public accessors

    var cscState: CscState = .default {
        didSet {
            hintCardCodeLabel.isHidden = false
            cardCodeTextView.isHidden = false

            switch cscState {
            case .default:
                setStyles(UIView.Styles.grayBorder)
                hintCardCodeLabel.setStyles(
                    UILabel.ColorStyle.ghost
                )

            case .selected:
                setStyles(UIView.Styles.grayBorder)
                hintCardCodeLabel.setStyles(
                    UILabel.ColorStyle.secondary
                )

            case .error:
                setStyles(UIView.Styles.alertBorder)
                hintCardCodeLabel.setStyles(
                    UILabel.ColorStyle.alert
                )

            case .noCVC:
                hintCardCodeLabel.isHidden = true
                cardCodeTextView.isHidden = true
            }
        }
    }

    var cardNumber: String {
        set {
            cardNumberLabel.styledText = newValue
        }
        get {
            return cardNumberLabel.styledText ?? ""
        }
    }

    var cardLogo: UIImage? {
        set {
            cardLogoImageView.image = newValue
        }
        get {
            return cardLogoImageView.image
        }
    }

    var hintCardNumber: String {
        set {
            hintCardNumberLabel.styledText = newValue
        }
        get {
            return hintCardNumberLabel.styledText ?? ""
        }
    }

    var hintCardCode: String {
        set {
            hintCardCodeLabel.styledText = newValue
        }
        get {
            return hintCardCodeLabel.styledText ?? ""
        }
    }

    var cardCodePlaceholder: String {
        set {
            cardCodeTextView.placeholder = newValue
        }
        get {
            return cardCodeTextView.placeholder ?? ""
        }
    }

    // MARK: - UI Propertie

    private(set) lazy var hintCardNumberLabel: UILabel = {
        $0.setStyles(
            UILabel.DynamicStyle.caption1,
            UILabel.ColorStyle.ghost,
            UILabel.Styles.singleLine
        )
        return $0
    }(UILabel())

    private(set) lazy var hintCardCodeLabel: UILabel = {
        $0.setStyles(
            UILabel.DynamicStyle.caption1,
            UILabel.ColorStyle.ghost,
            UILabel.Styles.singleLine
        )
        return $0
    }(UILabel())

    private(set) lazy var cardLogoImageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())

    private(set) lazy var cardNumberLabel: UILabel = {
        $0.setStyles(
            UILabel.DynamicStyle.body,
            UILabel.ColorStyle.secondary,
            UILabel.Styles.multiline
        )
        return $0
    }(UILabel())

    private(set) lazy var cardCodeTextView: UITextField = {
        $0.setStyles(
            UITextField.Styles.numeric,
            UITextField.Styles.left,
            UITextField.Styles.secure
        )
        $0.clearButtonMode = .never
        $0.delegate = self
        return $0
    }(UITextField())

    // MARK: - TintColor actions

    override func tintColorDidChange() {
        cardCodeTextView.tintColor = tintColor
        applyStyles()
    }

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
            top: Space.triple / 2,
            left: Space.double,
            bottom: Space.triple / 2,
            right: Space.double
        )
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            hintCardNumberLabel,
            hintCardCodeLabel,
            cardLogoImageView,
            cardNumberLabel,
            cardCodeTextView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    private func setupConstraints() {

        let constraints = [
            hintCardNumberLabel.top.constraint(equalTo: topMargin),
            hintCardNumberLabel.leading.constraint(equalTo: leadingMargin),
            hintCardNumberLabel.trailing.constraint(equalTo: hintCardCodeLabel.leading),

            hintCardCodeLabel.top.constraint(equalTo: topMargin),
            hintCardCodeLabel.leading.constraint(equalTo: cardCodeTextView.leading),

            cardLogoImageView.leading.constraint(equalTo: leadingMargin),
            cardLogoImageView.centerY.constraint(equalTo: cardNumberLabel.centerY),
            cardLogoImageView.height.constraint(equalToConstant: Constants.cardLogoImageHeight),
            cardLogoImageView.width.constraint(equalTo: cardLogoImageView.height),

            cardNumberLabel.top.constraint(
                equalTo: hintCardNumberLabel.bottom,
                constant: 6
            ),
            cardNumberLabel.leading.constraint(
                equalTo: cardLogoImageView.trailing,
                constant: Space.single
            ),
            cardNumberLabel.trailing.constraint(
                equalTo: cardCodeTextView.leading,
                constant: -Space.double
            ),
            cardNumberLabel.bottom.constraint(equalTo: bottomMargin),

            cardCodeTextView.centerY.constraint(equalTo: cardNumberLabel.centerY),
            cardCodeTextView.trailing.constraint(equalTo: trailingMargin),
            cardCodeTextView.width.constraint(equalToConstant: Constants.cardCodeTextViewWidth),
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - UITextFieldDelegate

extension MaskedCardView: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        return delegate?.textField(
            textField,
            shouldChangeCharactersIn: range,
            replacementString: string
        ) ?? true
    }

    func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        delegate?.textFieldDidBeginEditing(textField)
    }

    func textFieldDidEndEditing(
        _ textField: UITextField
    ) {
        delegate?.textFieldDidEndEditing(textField)
    }
}

// MARK: - Constants

private extension MaskedCardView {
    enum Constants {
        static let cardLogoImageHeight: CGFloat = 30
        static let cardCodeTextViewWidth: CGFloat = 42
    }
}
