import UIKit

final class LargeIconButtonItemViewCell: UITableViewCell {

    // MARK: - Public accessors

    var icon: UIImage {
        get {
            return itemView.image
        }
        set {
            itemView.image = newValue
        }
    }

    var title: String {
        get {
            return itemView.title
        }
        set {
            itemView.title = newValue
        }
    }

    var subtitle: String {
        get {
            return itemView.subtitle
        }
        set {
            itemView.subtitle = newValue
        }
    }

    var rightButtonTitle: String {
        get {
            return itemView.rightButtonTitle
        }
        set {
            itemView.rightButtonTitle = newValue
        }
    }

    var rightButtonPressHandler: (() -> Void)?

    // MARK: - Creating a View Object

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    // MARK: - UI properties

    private lazy var itemView: LargeIconButtonItemView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.output = self
        return $0
    }(LargeIconButtonItemView())

    // MARK: - Setup view
    private func setupView() {
        contentView.addSubview(itemView)

        let constraints = [
            itemView.leading.constraint(equalTo: contentView.leading),
            itemView.top.constraint(equalTo: contentView.top),
            contentView.trailing.constraint(equalTo: itemView.trailing),
            contentView.bottom.constraint(equalTo: itemView.bottom),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset.left = itemView.leftSeparatorInset + contentView.frame.minX
    }
}

extension LargeIconButtonItemViewCell: LargeIconButtonItemViewOutput {
    func didPressRightButton(in itemView: LargeIconButtonItemViewInput) {
        rightButtonPressHandler?()
    }
}
