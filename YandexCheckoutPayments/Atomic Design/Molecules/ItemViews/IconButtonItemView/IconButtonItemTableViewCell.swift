import UIKit

class IconButtonItemTableViewCell: UITableViewCell {

    var title: String {
        get {
            return itemView.title
        }
        set {
            itemView.title = newValue
        }
    }

    var icon: UIImage? {
        get {
            return itemView.image
        }
        set {
            itemView.image = newValue
        }
    }

    var buttonPressHandler: (() -> Void)?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    private lazy var itemView: IconButtonItemView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.output = self
        return $0
    }(IconButtonItemView())

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

// MARK: - IconButtonItemViewOutput

extension IconButtonItemTableViewCell: IconButtonItemViewOutput {
    func didPressButton(in itemView: IconButtonItemViewInput) {
        buttonPressHandler?()
    }
}
