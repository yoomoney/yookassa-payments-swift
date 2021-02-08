final class SectionHeaderView: UIView {

    // MARK: - Public accessors
    
    var title: String {
        set {
            titleLabel.styledText = newValue
        }
        get {
            return titleLabel.styledText ?? ""
        }
    }
    
    // MARK: - UI properties

    private(set) lazy var titleLabel = UILabel()

    // MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    deinit {
        unsubscribeFromNotifications()
    }

    // MARK: - Setup view
    
    private func setupView() {
        backgroundColor = .clear
        layoutMargins = UIEdgeInsets(
            top: Space.single,
            left: Space.double,
            bottom: Space.single,
            right: Space.double
        )
        setupSubviews()
        setupConstraints()
        subscribeOnNotifications()
    }

    private func setupSubviews() {
        let subviews: [UIView] = [
            titleLabel,
        ]
        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }

    private func setupConstraints() {
        let constraints = [
            titleLabel.left.constraint(equalTo: leftMargin),
            titleLabel.right.constraint(equalTo: rightMargin),
            titleLabel.top.constraint(equalTo: topMargin),
            titleLabel.bottom.constraint(equalTo: bottomMargin),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Accessibility
    @objc
    private func contentSizeCategoryDidChange() {
        titleLabel.applyStyles()
    }

    // MARK: - Notifications
    private func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension SectionHeaderView {
    enum Styles {
        /// Style for `footer` section header view.
        ///
        /// caption1, secondary color, multiline title.
        static let footer =
            InternalStyle(name: "SectionHeaderView.footer") { (item: SectionHeaderView) in
                item.titleLabel.setStyles(
                    UILabel.DynamicStyle.caption1,
                    UILabel.ColorStyle.secondary,
                    UILabel.Styles.multiline
                )
            }
        
        /// Style for `primary` section header view.
        ///
        /// headline1, primary color, multi line title.
        static let primary =
            InternalStyle(name: "SectionHeaderView.primary") { (item: SectionHeaderView) in
                item.titleLabel.setStyles(
                    UILabel.DynamicStyle.bodySemibold,
                    UILabel.ColorStyle.primary,
                    UILabel.Styles.multiline
                )
            }
    }
}
