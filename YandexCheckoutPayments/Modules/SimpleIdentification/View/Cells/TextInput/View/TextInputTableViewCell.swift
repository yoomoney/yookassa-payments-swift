import UIKit

final class TextInputTableViewCell: UITableViewCell {

    var output: TextInputTableViewCellOutput!

    var errorText: String?

    func configure(item: TextInputDisplayItem) {
        inputControl.delegate = output
        inputControl.topHint = item.title
        inputControl.placeholder = item.title
        inputControl.text = item.value
        inputControl.textView.isUserInteractionEnabled = item.isEnabled
        inputControl.set(bottomHintText: item.errorText, for: .error)
        inputControl.textView.keyboardType = item.keyboardType
        errorText = item.errorText
    }

    // MARK: - UI properties
    private lazy var inputControl: TextControl = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setStyles(TextControl.Styles.default,
                     TextControl.Styles.noAutocorrection)
        $0.textView.tintColor = UIColor.black
        return $0
    }(TextControl())

    // MARK: - Initialization/Deinitialization

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) is not implemented")
    }

    // MARK: - Managing the View

    func setupUI() {
        contentView.addSubview(inputControl)

        NSLayoutConstraint.activate([
            inputControl.leading.constraint(equalTo: contentView.leadingMargin),
            inputControl.top.constraint(equalTo: contentView.topMargin),
            contentView.trailingMargin.constraint(equalTo: inputControl.trailing),
            contentView.bottomMargin.constraint(equalTo: inputControl.bottom),
        ])
    }
}

extension TextInputTableViewCell: TextInputTableViewCellInput {

    var textControl: InputView {
        return inputControl
    }

    func showError() {
        inputControl.state = .error
    }

    func hideError() {
        inputControl.state = .default
    }
}
