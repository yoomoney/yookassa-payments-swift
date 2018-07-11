import UIKit

final class TextTableViewCell: UITableViewCell {

    func configure(item: TextDisplayItem) {
        label.styledText = item.text
    }

    // MARK: - UI properties

    fileprivate lazy var label: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setStyles(UILabel.DynamicStyle.caption2,
                     UILabel.Styles.multiline,
                     UILabel.Styles.disabled)
        return $0
    }(UILabel())

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
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leading.constraint(equalTo: contentView.leading, constant: Space.double),
            label.top.constraint(equalTo: contentView.top, constant: Space.double),
            contentView.trailing.constraint(equalTo: label.trailing, constant: Space.double),
            contentView.bottom.constraint(equalTo: label.bottom, constant: Space.single),
        ])
    }
}
