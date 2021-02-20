import UIKit

protocol SingleCharacterViewDelegate: class {
    func singleCharacterView(
        _ singleCharacterView: SingleCharacterView,
        didGetCharacter character: Character
    )
    func singleCharacterViewDidGetBackspaceCharacter(
        _ singleCharacterView: SingleCharacterView
    )
}

final class SingleCharacterView: UIView {

    private class ExtendedTextField: UITextField {

        weak var extendedDelegate: SingleCharacterView?

        override func deleteBackward() {
            super.deleteBackward()
            extendedDelegate?.textFieldDidDeleteBackward(self)
        }

        override func caretRect(for position: UITextPosition) -> CGRect {
            return .zero
        }
    }

    // MARK: - Public properties

    var character: Character? {
        get {
            return textField.text?.first
        }
        set {
            textField.text = newValue.map(String.init)
        }
    }

    var isEditable = true

    weak var delegate: SingleCharacterViewDelegate?

    // MARK: - UI properties

    private lazy var textField: UITextField = {
        let field = ExtendedTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.setStyles(
            UITextField.Styles.title3,
            UITextField.Styles.numeric,
            UITextField.Styles.center
        )
        if #available(iOS 12.0, *) {
            field.textContentType = .oneTimeCode
        }
        field.spellCheckingType = .no
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.delegate = self
        field.extendedDelegate = self
        return field
    }()

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // First responder

    override var isFirstResponder: Bool {
        return textField.isFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }

    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
}

// Private methods

private extension SingleCharacterView {

    func setup() {
        layer.cornerRadius = Space.single
        backgroundColor = UIColor.AdaptiveColors.mousegrey
        isUserInteractionEnabled = false

        addSubview(textField)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48),
            widthAnchor.constraint(equalToConstant: 30),

            textField.centerXAnchor.constraint(equalTo: centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

// MARK: - UITextFieldDelegate

extension SingleCharacterView: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard isEditable else { return false }

        if range.location == 0 {
            character = string.first
        }
        if let character = character {
            delegate?.singleCharacterView(self, didGetCharacter: character)
        }
        return false
    }

    func textFieldDidDeleteBackward(_ textField: UITextField) {
        guard isEditable else { return }

        delegate?.singleCharacterViewDidGetBackspaceCharacter(self)
    }
}
