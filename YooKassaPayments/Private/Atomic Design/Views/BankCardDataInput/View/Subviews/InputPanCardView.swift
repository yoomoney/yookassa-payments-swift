import UIKit

protocol InputPanCardViewDelegate: class {
    func panDidChange(
        _ value: String
    )
    func scanDidPress()
    func nextDidPress()
    func panDidBeginEditing()
    func clearDidPress()
}

final class InputPanCardView: UIView {

    enum RightButtonMode {
        case empty
        case clear
        case scan
        case next
    }

    // MARK: - InputPanCardViewDelegate

    weak var delegate: InputPanCardViewDelegate?

    // MARK: - Public accessors

    var hint: String? {
        get {
            cardPanHintLabel.text
        }
        set {
            cardPanHintLabel.text = newValue
        }
    }

    var logo: UIImage? {
        get {
            cardPanLogoImageView.image
        }
        set {
            cardPanLogoImageView.image = newValue
            cardPanLogoImageView.isHidden = newValue == nil
        }
    }

    var text: String? {
        get {
            cardPanTextField.text
        }
        set {
            cardPanTextField.text = inputPresenter
                .style
                .appendedFormatting(
                to: newValue ?? ""
            )
        }
    }

    var placeholder: String? {
        get {
            cardPanTextField.placeholder
        }
        set {
            cardPanTextField.placeholder = newValue
        }
    }

    var rightButtonMode: RightButtonMode {
        get {
            cardPanRightButtonMode
        }
        set {
            cardPanRightButtonMode = newValue
            setupCardPanRightButtonMode(newValue)
        }
    }

    // MARK: - UI properties

    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()

    private lazy var horizontalStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = Space.single
        view.distribution = .fillProportionally
        return view
    }()

    private lazy var cardPanHintLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyles(
            UILabel.DynamicStyle.caption1,
            UILabel.ColorStyle.ghost,
            UILabel.Styles.singleLine
        )
        return view
    }()

    private lazy var cardPanLogoImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        return view
    }()

    private(set) lazy var cardPanTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyles(UITextField.Styles.numeric)
        view.tintColor = CustomizationStorage.shared.mainScheme
        view.delegate = self
        return view
    }()

    private lazy var cardPanRightButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(cardPanRightButtonDidPress(_:)), for: .touchUpInside)
        return view
    }()

    // MARK: - Input presenter

    private lazy var inputPresenter: InputPresenter = {
        let textInputStyle = PanInputPresenterStyle()
        let inputPresenter = InputPresenter(
            textInputStyle: textInputStyle
        )
        inputPresenter.output = cardPanTextField
        return inputPresenter
    }()

    // MARK: - Logic properties

    private var cardPanRightButtonMode: RightButtonMode = .empty

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    // MARK: - Setup view

    private func setupView() {
        backgroundColor = .clear
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            verticalStackView
        ].forEach(addSubview)
        [
            cardPanHintLabel,
            horizontalStackView,
        ].forEach(verticalStackView.addArrangedSubview)
        [
            cardPanLogoImageView,
            cardPanTextField,
            cardPanRightButton,
        ].forEach(horizontalStackView.addArrangedSubview)
    }

    private func setupConstraints() {
        let constraints = [
            verticalStackView.topAnchor.constraint(equalTo: topAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),

            cardPanRightButton.widthAnchor.constraint(equalToConstant: Space.triple),

            cardPanLogoImageView.widthAnchor.constraint(equalToConstant: 30),
            cardPanLogoImageView.heightAnchor.constraint(equalToConstant: 30),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func setupCardPanRightButtonMode(
        _ buttonMode: RightButtonMode
    ) {
        switch buttonMode {
        case .empty:
            cardPanRightButton.setImage(nil, for: .normal)
            cardPanRightButton.isHidden = true
        case .clear:
            cardPanRightButton.setImage(.clear, for: .normal)
            cardPanRightButton.isHidden = false
        case .scan:
            let image = UIImage.PaymentSystem.TextControl.scan.colorizedImage(
                color: CustomizationStorage.shared.mainScheme
            )
            cardPanRightButton.setImage(image, for: .normal)
            cardPanRightButton.isHidden = false

        case .next:
            let image = UIImage.named("action_forward").colorizedImage(
                color: CustomizationStorage.shared.mainScheme
            )
            cardPanRightButton.setImage(image, for: .normal)
            cardPanRightButton.isHidden = false
        }
    }
}

// MARK: - UITextFieldDelegate

extension InputPanCardView: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        inputPresenter.input(
            changeCharactersIn: range,
            replacementString: string,
            currentString: cardPanTextField.text ?? ""
        )
        let value = inputPresenter.style.removedFormatting(
            from: cardPanTextField.text ?? ""
        )
        delegate?.panDidChange(value)
        return false
    }

    func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        delegate?.panDidBeginEditing()
    }
}

// MARK: - Actions

@objc
private extension InputPanCardView {
    func cardPanRightButtonDidPress(
        _ sender: UIButton
    ) {
        switch rightButtonMode {
        case .empty:
            break
        case .clear:
            cardPanTextField.text = ""
            delegate?.panDidChange("")
            delegate?.clearDidPress()
        case .scan:
            delegate?.scanDidPress()
        case .next:
            delegate?.nextDidPress()
        }
    }
}

// MARK: Styles

extension InputPanCardView {
    enum Styles {
        static let `default` = InternalStyle(name: "InputPanCardView.Default") { (view: InputPanCardView) in
            view.cardPanHintLabel.setStyles(
                UILabel.DynamicStyle.caption1,
                UILabel.ColorStyle.ghost,
                UILabel.Styles.singleLine
            )
        }
        static let error = InternalStyle(name: "InputPanCardView.Error") { (view: InputPanCardView) in
            view.cardPanHintLabel.setStyles(
                UILabel.DynamicStyle.caption1,
                UILabel.ColorStyle.alert,
                UILabel.Styles.singleLine
            )
        }
    }
}
