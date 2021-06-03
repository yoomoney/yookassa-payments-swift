import UIKit

final class PhoneNumberInputView: UIView {

    // MARK: - VIPER

    var output: PhoneNumberInputViewOutput!

    // MARK: - Input presenter

    var textInputStyle: InputPresenterStyle!

    private lazy var inputPresenter: InputPresenter = {
        let inputPresenter = InputPresenter(
            textInputStyle: textInputStyle
        )
        inputPresenter.output = textField
        return inputPresenter
    }()

    // MARK: - UI properties

    private lazy var contentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyles(UIView.Styles.grayBackground)
        view.axis = .vertical
        view.spacing = 12
        return view
    }()

    private lazy var textField: UnderlinedTextField = {
        let view = UnderlinedTextField()
        view.setStyles(UnderlinedTextField.Styles.default,
                       UnderlinedTextField.Styles.phone)
        view.tintColor = CustomizationStorage.shared.mainScheme
        view.delegate = self
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.setStyles(
            UILabel.DynamicStyle.caption2,
            UILabel.ColorStyle.secondary
        )
        return view
    }()

    private lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.setStyles(
            UILabel.DynamicStyle.caption2,
            UILabel.ColorStyle.secondary
        )
        return view
    }()

    // MARK: - Managing the View

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        layoutMargins = UIEdgeInsets(
            top: Space.double,
            left: Space.double,
            bottom: Space.double,
            right: Space.double
        )
        setStyles(UIView.Styles.defaultBackground)
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            contentStackView,
        ].forEach(addSubview)
        [
            titleLabel,
            textField,
            subtitleLabel,
        ].forEach(contentStackView.addArrangedSubview)
    }

    private func setupConstraints() {
        let constraints = [
            contentStackView.leadingAnchor.constraint(
                equalTo: layoutMarginsGuide.leadingAnchor
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: layoutMarginsGuide.trailingAnchor
            ),
            contentStackView.topAnchor.constraint(
                equalTo: layoutMarginsGuide.topAnchor
            ),
            contentStackView.bottomAnchor.constraint(
                equalTo: layoutMarginsGuide.bottomAnchor
            ),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - PhoneNumberInputViewInput

extension PhoneNumberInputView: PhoneNumberInputViewInput {
    func setValue(_ value: String) {
        textField.text = textInputStyle.appendedFormatting(to: value)
    }

    func setPlaceholder(_ value: String) {
        textField.placeholder = value
    }

    func setTitle(_ value: String) {
        titleLabel.text = value
    }

    func setSubtitle(_ value: String) {
        subtitleLabel.text = value
    }

    func markTextFieldValid(_ isValid: Bool) {
        textField.lineViewBackgroundColor = isValid
            ? CustomizationStorage.shared.mainScheme
            : .red
    }
}

// MARK: - UnderlinedTextFieldDelegate

extension PhoneNumberInputView: UnderlinedTextFieldDelegate {
    func textFieldDidEndEditing(
        _ textField: UITextField
    ) {
        output.didFinishChangePhoneNumber()
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        inputPresenter.input(
            changeCharactersIn: range,
            replacementString: string,
            currentString: textField.text ?? ""
        )
        let phoneNumber = textInputStyle.removedFormatting(
            from: textField.text ?? ""
        )
        output.phoneNumberDidChange(on: phoneNumber)
        return false
    }
}
