import UIKit
import YandexCheckoutPayments

class TextHeaderFooterView: UITableViewHeaderFooterView {

    // MARK: - Public properties

    var title: String? {
        get {
            return titleLabel.styledText
        }
        set {
            titleLabel.styledText = newValue
        }
    }

    // MARK: - UI properties

    private lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.setStyles(UILabel.DynamicStyle.caption1,
                     UILabel.ColorStyle.secondary,
                     UILabel.Styles.alignLeft,
                     UILabel.Styles.uppercased,
                     UILabel.Styles.multiline)

        return $0
    }(UILabel())

    // MARK: - Initialization/Deinitialization

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) is not implemented")
    }

    // MARK: - Private methods

    private func setupUI() {
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            contentView.leadingMargin.constraint(equalTo: titleLabel.leading),
            contentView.trailingMargin.constraint(equalTo: titleLabel.trailing),
            contentView.bottomMargin.constraint(equalTo: titleLabel.bottom),
            titleLabel.top.constraint(equalTo: contentView.topMargin, constant: Space.quadruple),
        ])
    }

}
