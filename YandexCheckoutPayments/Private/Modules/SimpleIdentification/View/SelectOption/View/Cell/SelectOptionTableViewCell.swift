import UIKit

final class SelectOptionTableViewCell: UITableViewCell {

    func configure(item: SelectOptionDisplayItem) {
        label.styledText = item.label
    }

    func setCheck(_ check: Bool) {
        checkImageView.isHidden = !check
    }

    // MARK: - UI properties

    private lazy var label: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setStyles(UILabel.DynamicStyle.headline1, UILabel.Styles.multiline)
        return $0
    }(UILabel())

    private lazy var separatorView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.gallery
        return $0
    }(UIView())

    private lazy var checkImageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
    }(UIImageView(image: UIImage.named("Common.check.success")))

    // MARK: - Initialization/Deinitialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) is not implemented")
    }

    // MARK: - Managing the View

    func setupUI() {
        selectionStyle = .none

        contentView.addSubview(label)
        contentView.addSubview(separatorView)
        contentView.addSubview(checkImageView)

        NSLayoutConstraint.activate([
            label.leading.constraint(equalTo: contentView.leading, constant: Space.double),
            label.top.constraint(equalTo: contentView.top, constant: Space.triple),
            checkImageView.leading.constraint(equalTo: label.trailing, constant: Space.double),

            separatorView.leading.constraint(equalTo: contentView.leading, constant: Space.double),
            separatorView.top.constraint(equalTo: label.bottom, constant: Space.single),
            contentView.trailing.constraint(equalTo: separatorView.trailing, constant: Space.double),
            contentView.bottom.constraint(equalTo: separatorView.bottom),
            separatorView.height.constraint(equalToConstant: 1),

            contentView.trailing.constraint(equalTo: checkImageView.trailing, constant: Space.double),
            checkImageView.centerY.constraint(equalTo: label.centerY),
        ])
    }
}
