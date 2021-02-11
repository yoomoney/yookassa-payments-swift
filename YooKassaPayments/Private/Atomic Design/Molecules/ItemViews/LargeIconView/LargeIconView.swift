final class LargeIconView: UIView {
    
    // MARK: - Public accessors
    
    var image: UIImage {
        set {
            imageView.image = newValue
        }
        get {
            return imageView.image ?? UIImage()
        }
    }

    var title: String {
        set {
            titleLabel.styledText = newValue
        }
        get {
            return titleLabel.styledText ?? ""
        }
    }
    
    // MARK: - UI properties
    
    private(set) lazy var imageView: UIImageView = {
        $0.setStyles(UIImageView.Styles.dynamicSize)
        return $0
    }(UIImageView())

    private(set) lazy var titleLabel: UILabel = {
        $0.setStyles(UILabel.DynamicStyle.body,
                     UILabel.ColorStyle.primary,
                     UILabel.Styles.multiline)
        return $0
    }(UILabel())
    
    // MARK: - Creating a View Object.
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    // MARK: - Setup view
    
    private func setupView() {
        backgroundColor = .clear
        layoutMargins = UIEdgeInsets(
            top: Space.double,
            left: Space.double,
            bottom: Space.double,
            right: Space.double
        )
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            imageView,
            titleLabel,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    private func setupConstraints() {
        let constraints = [
            imageView.top.constraint(equalTo: topMargin),
            imageView.leading.constraint(equalTo: leadingMargin),
            imageView.height.constraint(equalToConstant: Space.fivefold),
            imageView.width.constraint(equalTo: imageView.height),
            
            titleLabel.top.constraint(equalTo: topMargin),
            titleLabel.leading.constraint(
                equalTo: imageView.trailing,
                constant: Space.double
            ),
            titleLabel.trailing.constraint(equalTo: trailingMargin),
            titleLabel.bottom.constraint(equalTo: bottomMargin),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
