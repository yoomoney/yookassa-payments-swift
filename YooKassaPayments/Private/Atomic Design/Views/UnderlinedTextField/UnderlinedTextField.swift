import UIKit

protocol UnderlinedTextFieldDelegate: class {
    func textFieldDidEndEditing(
        _ textField: UITextField
    )
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool
}

final class UnderlinedTextField: UIView {

    // MARK: - UnderlinedTextFieldDelegate

    weak var delegate: UnderlinedTextFieldDelegate?

    // MARK: - Public accessors

    var text: String? {
        didSet {
            textField.text = text
        }
    }

    var placeholder: String? {
        didSet {
            textField.placeholder = placeholder
        }
    }

    var lineViewBackgroundColor: UIColor? {
        didSet {
            lineView.backgroundColor = lineViewBackgroundColor
        }
    }

    // MARK: - UI properties

    private lazy var contentStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = Space.single
        return view
    }()

    private(set) lazy var textField: UITextField = {
        let view = UITextField()
        view.setStyles(UITextField.Styles.default,
                       UITextField.Styles.phone)
        view.delegate = self
        return view
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyles(UIView.Styles.separator)
        return view
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - SetupView

    private func setupView() {
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            contentStackView,
        ].forEach(addSubview)
        [
            textField,
            lineView,
        ].forEach(contentStackView.addArrangedSubview)
    }

    private func setupConstraints() {
        let constraints = [
            contentStackView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            contentStackView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
            contentStackView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            contentStackView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            lineView.heightAnchor.constraint(
                equalToConstant: 1
            ),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Drawing and Updating the View

    override func tintColorDidChange() {
        super.tintColorDidChange()
        textField.tintColor = tintColor
        lineView.tintColor = tintColor
    }
}

// MARK: - UITextFieldDelegate

extension UnderlinedTextField: UITextFieldDelegate {
    func textFieldDidEndEditing(
        _ textField: UITextField
    ) {
        delegate?.textFieldDidEndEditing(
            textField
        )
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let delegate = delegate else { return true }
        return delegate.textField(
            textField,
            shouldChangeCharactersIn: range,
            replacementString: string
        )
    }

    func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        lineView.backgroundColor = CustomizationStorage.shared.mainScheme
    }

    func textFieldDidEndEditing(
        _ textField: UITextField,
        reason: UITextField.DidEndEditingReason
    ) {
        lineView.setStyles(UIView.Styles.separator)
    }
}
