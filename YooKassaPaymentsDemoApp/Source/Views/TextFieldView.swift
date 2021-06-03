import UIKit

class TextFieldView: UIView {

    // MARK: - Delegate

    var valueChangeHandler: ((String?) -> Void)?

    // MARK: - Public properties

    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }

    var placeholder: String? {
        get {
            return textField.placeholder
        }
        set {
            textField.placeholder = newValue
        }
    }

    // MARK: - UI properties

    private lazy var textField: UITextField = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )
        return $0
    }(UITextField())

    // MARK: - Initialization/Deinitialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) is not implemented")
    }

    // MARK: - Private methods

    private func setupUI() {
        [
            textField,
        ].forEach(addSubview)
        setupConstraints()
    }

    private func setupConstraints() {
        let constraints = [
            textField.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: Space.single),
            textField.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -Space.single),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions

    @objc
    private func textFieldDidChange(textField: UITextField) {
        valueChangeHandler?(textField.text)
    }
}

// MARK: - TableViewCellDataProviderSupport

extension TextFieldView: TableViewCellDataProviderSupport {
    class var estimatedCellHeight: CGFloat {
        return 56.0
    }
}
