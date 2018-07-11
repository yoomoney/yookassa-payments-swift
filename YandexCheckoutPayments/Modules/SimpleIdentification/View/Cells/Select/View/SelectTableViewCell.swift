import UIKit

final class SelectTableViewCell: UITableViewCell {

    var output: SelectTableViewCellOutput!

    func configure(item: SelectDisplayItem) {
        inputControl.topHint = item.title
        inputControl.placeholder = item.title
        if item.value != nil {
            inputControl.setStyles(UILabel.Styles.primary)
        } else {
            inputControl.setStyles(UILabel.Styles.disabled)
        }
    }

    func setLocalizedValue(_ value: String?) {
        inputControl.text = value
    }

    // MARK: - UI properties
    private lazy var inputControl: TextControl = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isUserInteractionEnabled = false
        $0.setStyles(TextControl.Styles.default)
        $0.textView.tintColor = UIColor.black
        return $0
    }(TextControl())

    fileprivate lazy var hiddenButton: UIButton = {
        $0.addTarget(self, action: #selector(selectButtonDidPressed), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton(type: .custom))

    private lazy var arrowImageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
    }(UIImageView(image: UIImage.named("Common.arrow.right")))

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
        contentView.addSubview(arrowImageView)
        contentView.addSubview(hiddenButton)

        NSLayoutConstraint.activate([
            inputControl.leading.constraint(equalTo: contentView.leadingMargin),
            inputControl.top.constraint(equalTo: contentView.topMargin),
            contentView.bottomMargin.constraint(equalTo: inputControl.bottom),

            hiddenButton.leading.constraint(equalTo: contentView.leadingMargin),
            hiddenButton.top.constraint(equalTo: contentView.topMargin),
            contentView.trailingMargin.constraint(equalTo: hiddenButton.trailing),
            contentView.bottomMargin.constraint(equalTo: hiddenButton.bottom),

            contentView.trailingMargin.constraint(equalTo: arrowImageView.trailing),
            arrowImageView.centerY.constraint(equalTo: inputControl.centerY),
            arrowImageView.leading.constraint(equalTo: inputControl.trailing),
        ])
    }

    // MARK: - Actions

    @objc
    private func selectButtonDidPressed() {
        output.selectDidPress(in: self)
    }
}
