import UIKit

class ContainerTableViewCell<ContainedView: UIView & TableViewCellDataProviderSupport>: UITableViewCell {

    // MARK: - Public properties

    lazy var containedView: ContainedView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.preservesSuperviewLayoutMargins = true
        return $0
    }(ContainedView())

    // MARK: - Initialization/Deinitialization

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
            contentView.leading.constraint(equalTo: containedView.leading),
            contentView.top.constraint(equalTo: containedView.top),
            contentView.trailing.constraint(equalTo: containedView.trailing),
            contentView.bottom.constraint(equalTo: containedView.bottom),
            ])
    }

}

extension ContainerTableViewCell: TableViewCellDataProviderSupport {

    static var estimatedCellHeight: CGFloat {
        return ContainedView.estimatedCellHeight
    }

}
