import UIKit

class ContainerTableViewCell<ContainedView: UIView & TableViewCellDataProviderSupport>: UITableViewCell {

    // MARK: - Public properties

    lazy var containedView: ContainedView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.preservesSuperviewLayoutMargins = true
        return $0
    }(ContainedView())

    // MARK: - Initialization/Deinitialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init?(coder:) is not implemented")
    }

    // MARK: - Private methods

    func setupUI() {
        contentView.addSubview(containedView)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: containedView.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: containedView.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: containedView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: containedView.bottomAnchor),
        ])
    }
}

extension ContainerTableViewCell: TableViewCellDataProviderSupport {
    static var estimatedCellHeight: CGFloat {
        return ContainedView.estimatedCellHeight
    }
}
