import UIKit

protocol InputCvcViewDelegate: AnyObject {
    func cvcDidChange(
        _ value: String
    )
    func cvcDidEndEditing()
}

final class InputCvcView: UIView {

    // MARK: - InputCvcViewDelegate

    weak var delegate: InputCvcViewDelegate?

    // MARK: - Public accessors

    var hint: String? {
        get {
            cvcHintLabel.text
        }
        set {
            cvcHintLabel.text = newValue
        }
    }

    var text: String? {
        get {
            cvcTextField.text
        }
        set {
            cvcTextField.text = newValue
        }
    }

    var placeholder: String? {
        get {
            cvcTextField.placeholder
        }
        set {
            cvcTextField.placeholder = newValue
        }
    }

    // MARK: - UI properties

    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()

    private lazy var cvcHintLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyles(
            UILabel.DynamicStyle.caption1,
            UILabel.ColorStyle.ghost,
            UILabel.Styles.singleLine
        )
        return view
    }()

    private(set) lazy var cvcTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyles(UITextField.Styles.numeric)
        view.delegate = self
        return view
    }()

    // MARK: - Input presenter

    private lazy var inputPresenter: InputPresenter = {
        let textInputStyle = CscInputPresenterStyle()
        let inputPresenter = InputPresenter(
            textInputStyle: textInputStyle
        )
        inputPresenter.output = cvcTextField
        return inputPresenter
    }()

    // MARK: - Stored properties

    private var cachedCvc = ""

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    // MARK: - SetupView

    private func setupView() {
        backgroundColor = .clear
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            verticalStackView,
        ].forEach(addSubview)
        [
            cvcHintLabel,
            cvcTextField,
        ].forEach(verticalStackView.addArrangedSubview)
    }

    private func setupConstraints() {
        let constraints = [
            verticalStackView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            verticalStackView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
            verticalStackView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            verticalStackView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),

            cvcTextField.heightAnchor.constraint(equalToConstant: 30),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - UITextFieldDelegate

extension InputCvcView: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let replacementText = cachedCvc.count < inputPresenter.style.maximalLength ? string : ""
        let cvc = (cachedCvc as NSString).replacingCharacters(in: range, with: replacementText)
        cachedCvc = inputPresenter.style.removedFormatting(from: cvc)

        inputPresenter.input(
            changeCharactersIn: range,
            replacementString: string,
            currentString: cvcTextField.text ?? ""
        )

        delegate?.cvcDidChange(cachedCvc)
        return false
    }

    func textFieldDidEndEditing(
        _ textField: UITextField
    ) {
        delegate?.cvcDidEndEditing()
    }
}

// MARK: Styles

extension InputCvcView {
    enum Styles {
        static let `default` = InternalStyle(name: "InputCvcView.Default") { (view: InputCvcView) in
            view.cvcHintLabel.setStyles(
                UILabel.DynamicStyle.caption1,
                UILabel.ColorStyle.ghost,
                UILabel.Styles.singleLine
            )
        }
        static let error = InternalStyle(name: "InputCvcView.Error") { (view: InputCvcView) in
            view.cvcHintLabel.setStyles(
                UILabel.DynamicStyle.caption1,
                UILabel.ColorStyle.alert,
                UILabel.Styles.singleLine
            )
        }
    }
}
