import UIKit
import YooKassaPayments

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
            contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            titleLabel.layoutMarginsGuide.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                               constant: Space.quadruple),
        ])
    }

}
