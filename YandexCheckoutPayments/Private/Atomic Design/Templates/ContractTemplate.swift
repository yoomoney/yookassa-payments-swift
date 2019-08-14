import FunctionalSwift
import UIKit

protocol ContractTemplateViewOutput: class {
    func didPressSubmitButton(in contractTemplate: ContractTemplateViewInput)
    func didTapContract(_ contractTemplate: ContractTemplateViewInput)
    func didTapTermsOfService(_ url: URL)
}

protocol ContractTemplateViewInput: class {
    func setShopName(_ shopName: String)
    func setPurchaseDescription(_ purchaseDescription: String)
    func setPrice(_ price: PriceViewModel)
    func setFee(_ fee: PriceViewModel?)
    func setSubmitButtonEnabled(_ isEnabled: Bool)
    func setTermsOfService(text: String, hyperlink: String, url: URL)
}

final class ContractTemplate: UIViewController {

    // MARK: - Data properties

    var shopName: String {
        set {
            titleLabel.styledText = newValue
        }
        get {
            return titleLabel.styledText ?? ""
        }
    }

    var purchaseDescription: String {
        set {
            descriptionLabel.styledText = newValue
        }
        get {
            return descriptionLabel.styledText ?? ""
        }
    }

    var price: PriceViewModel? {
        set {
            priceView.price = newValue
        }
        get {
            return priceView.price
        }
    }

    var fee: PriceViewModel? {
        set {
            feeView.price = newValue
            newValue == nil
                ? configurePriceView()
                : configureFeeView()
        }
        get {
            return feeView.price
        }
    }

    weak var output: ContractTemplateViewOutput?

    // MARK: - Touches, Presses, and Gestures

    private lazy var viewTapGestureRecognizer: UITapGestureRecognizer = {
        $0.delegate = self
        return $0
    }(UITapGestureRecognizer(target: self, action: #selector(viewTapGestureRecognizerHandle(_:))))

    // MARK: - UI properties

    private var backgroundStyle = UIView.Styles.grayBackground

    fileprivate lazy var headerView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    fileprivate lazy var titleLabel: UILabel = {
        let style: Style
        if #available(iOS 9.0, *) {
            style = UILabel.DynamicStyle.title2
        } else {
            style = UILabel.DynamicStyle.headline1
        }
        $0.setStyles(style, UILabel.Styles.multiline, UIView.Styles.heightAsContent)
        return $0
    }(UILabel())

    fileprivate lazy var descriptionLabel: UILabel = {
        $0.setStyles(UILabel.DynamicStyle.body,
                     UILabel.ColorStyle.secondary,
                     UILabel.Styles.multiline,
                     backgroundStyle,
                     UIView.Styles.heightAsContent)
        return $0
    }(UILabel())

    fileprivate lazy var descriptionLabelSeparator: UIView = {
        $0.setStyles(UIView.Styles.separator)
        return $0
    }(UIView())

    var paymentMethodView: UIView? {
        didSet {
            if let oldView = oldValue, paymentMethodView !== oldView {
                oldView.removeFromSuperview()
                paymentMethodViewSeparator.removeFromSuperview()
            }
            if paymentMethodView !== oldValue {
                configurePaymentMethodView()
            }
        }
    }

    fileprivate lazy var paymentMethodViewSeparator: UIView = {
        $0.setStyles(UIView.Styles.separator)
        return $0
    }(UIView())

    fileprivate var paymentMethodViewSeparatorLeading: NSLayoutConstraint?

    fileprivate lazy var priceView: PriceView = {
        $0.layoutMargins = .zero
        $0.setStyles(backgroundStyle, UIView.Styles.heightAsContent)
        $0.text = §Localized.price
        return $0
    }(PriceView())

    private lazy var feeView: PriceView = {
        let view = PriceView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = .zero
        view.setStyles(backgroundStyle, UIView.Styles.heightAsContent)
        view.text = §Localized.fee
        return view
    }()

    private lazy var termsOfServiceTextView: LinkedTextView = {
        let view = LinkedTextView()
        view.setStyles(backgroundStyle,
                       UITextView.Styles.linked)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    var footerView: UIView? {
        didSet {
            if let oldView = oldValue, footerView !== oldView {
                oldView.removeFromSuperview()
                footerViewSeparator.removeFromSuperview()
            }
            if footerView !== oldValue {
                configureFooterView()
            }
        }
    }

    fileprivate lazy var footerViewSeparator: UIView = {
        $0.setStyles(UIView.Styles.separator)
        return $0
    }(UIView())

    fileprivate var footerViewSeparatorLeading: NSLayoutConstraint?

    fileprivate lazy var submitButton: Button = {
        $0.setStyles(UIButton.DynamicStyle.primary,
                     UIView.Styles.heightAsContent)
        $0.setStyledTitle(§Localized.continue, for: .normal)
        $0.addTarget(self, action: #selector(submitButtonDidPress), for: .touchUpInside)
        return $0
    }(Button(type: .custom))

    fileprivate var descriptionLabelBottomConstraint: NSLayoutConstraint?

    fileprivate var priceViewTopConstraint: NSLayoutConstraint?

    fileprivate var scrollViewHeightConstraint: NSLayoutConstraint?

    fileprivate lazy var scrollView: UIScrollView = {
        $0.setStyles(backgroundStyle)
        if #available(iOS 11, *) {
            $0.insetsLayoutMarginsFromSafeArea = true
        }
        return $0
    }(UIScrollView())

    fileprivate lazy var contentView = UIView()

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.setStyles(backgroundStyle)
        view.addGestureRecognizer(viewTapGestureRecognizer)

        loadSubviews()
        loadConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeOnNotifications()
    }

    private func loadSubviews() {
        let subviews: [UIView] = [
            scrollView,
            headerView,
            submitButton,
        ]

        headerView.contentView.addSubview(titleLabel)

        view.addSubview <^> subviews
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true

        contentView.setStyles(backgroundStyle)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        let views: [UIView] = [
            descriptionLabel,
            descriptionLabelSeparator,
            priceView,
            termsOfServiceTextView,
        ]

        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        contentView.addSubview <^> views
    }

    private func loadConstraints() {

        var constraints = [
            scrollView.leading.constraint(equalTo: contentView.leading),
            scrollView.top.constraint(equalTo: contentView.top),
            scrollView.trailing.constraint(equalTo: contentView.trailing),
            scrollView.bottom.constraint(equalTo: contentView.bottom),
            contentView.width.constraint(equalTo: view.width),
        ]

        let descriptionLabelBottomConstraint = priceView.top.constraint(equalTo: descriptionLabel.bottom,
                                                                        constant: Space.double)

        self.descriptionLabelBottomConstraint = descriptionLabelBottomConstraint
        self.priceViewTopConstraint = descriptionLabelBottomConstraint

        let titleFormat = "V:|[headerView]"

        let topFormat = [
            "V:",
            "|",
            "[scrollView]",
            "-(double)-",
            "[submitButton]",
        ].joined()

        let bottomFormat = "V:[priceView]"

        let formats = [
            titleFormat,
            topFormat,
            bottomFormat,
        ]

        var views: [String: Any] = [
            "scrollView": scrollView,
            "descriptionLabel": descriptionLabel,
            "priceView": priceView,
            "termsOfService": termsOfServiceTextView,
            "submitButton": submitButton,
            "headerView": headerView,
        ]

        func makeConstraints(format: String) -> [NSLayoutConstraint] {
            return NSLayoutConstraint.constraints(withVisualFormat: format, metrics: Space.metrics, views: views)
        }

        constraints += makeConstraints -<< formats

        views["scrollView"] = nil
        views["headerView"] = nil

        let horizontalFormats = views.keys.map { ["H:|-(double)-[", $0, "]-(double)-|"].joined() }

        constraints += [
            titleLabel.top.constraint(equalTo: headerView.top, constant: Space.double),
            headerView.bottom.constraint(equalTo: titleLabel.bottom, constant: Space.double),
            titleLabel.leading.constraint(equalTo: headerView.leading, constant: Space.double),
            headerView.trailing.constraint(equalTo: titleLabel.trailing, constant: Space.double),

            scrollView.leading.constraint(equalTo: view.leading),
            scrollView.trailing.constraint(equalTo: view.trailing),
            headerView.leading.constraint(equalTo: view.leading),
            headerView.trailing.constraint(equalTo: view.trailing),
            contentView.top.constraint(equalTo: descriptionLabel.top),

            descriptionLabelSeparator.top.constraint(equalTo: descriptionLabel.bottom, constant: Space.double),
            descriptionLabelSeparator.leading.constraint(equalTo: descriptionLabel.leading),
            descriptionLabelSeparator.trailing.constraint(equalTo: contentView.trailing),

            view.bottomMargin.constraint(equalTo: submitButton.bottom, constant: Space.double),
        ]

        constraints += makeConstraints -<< horizontalFormats
        constraints.append(descriptionLabelBottomConstraint)

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Configuring the View’s Layout Behavior

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.scrollIndicatorInsets.top = headerView.frame.height
        scrollView.contentInset = scrollView.scrollIndicatorInsets

        fixSeparator()

        DispatchQueue.main.async {
            self.fixScrollViewHeight()
        }
    }

    private func fixSeparator() {
        if let itemView = paymentMethodView as? ListItemView,
            let leading = paymentMethodViewSeparatorLeading {
            leading.constant = itemView.leftSeparatorInset
        }

        if let itemView = footerView as? ListItemView,
           let leading = footerViewSeparatorLeading {
            leading.constant = itemView.leftSeparatorInset
        }
    }

    private func fixScrollViewHeight() {
        var scrollViewHeightConstraint: NSLayoutConstraint! {
            return self.scrollViewHeightConstraint
        }

        let newValue = contentView.bounds.height
            + scrollView.contentInset.top

        if self.scrollViewHeightConstraint == nil {
            view.setNeedsLayout()
            self.scrollViewHeightConstraint = scrollView.height.constraint(equalToConstant: newValue)
            scrollViewHeightConstraint.priority = .defaultHigh
            scrollViewHeightConstraint.isActive = true
        } else if scrollViewHeightConstraint.constant < newValue {
            view.setNeedsLayout()
            scrollViewHeightConstraint.constant = newValue
        }

        view.layoutIfNeeded()
    }

    // MARK: - Accessibility

    @objc
    private func accessibilityReapply() {
        titleLabel.styledText = titleLabel.text
        descriptionLabel.styledText = descriptionLabel.text
    }

    // MARK: - Notifications

    private func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(accessibilityReapply),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Actions

    @objc
    private func submitButtonDidPress() {
        output?.didPressSubmitButton(in: self)
    }

    @objc
    private func viewTapGestureRecognizerHandle(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .recognized else { return }
        output?.didTapContract(self)
    }

    // MARK: - Configuring optional subviews

    private func configurePaymentMethodView() {
        guard let paymentMethodView = paymentMethodView else { return }

        paymentMethodView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(paymentMethodView)

        paymentMethodView.appendStyle(UIView.Styles.heightAsContent)

        let bottomView = footerView ?? priceView

        let topConstraint = paymentMethodView.top.constraint(equalTo: descriptionLabelSeparator.bottom)
        let bottomViewConstraint = bottomView.top.constraint(equalTo: paymentMethodView.bottom,
                                                             constant: Space.quadruple)

        var constraints = [
            paymentMethodView.leading.constraint(equalTo: contentView.leading, constant: Space.double),
            contentView.trailing.constraint(equalTo: paymentMethodView.trailing, constant: Space.double),
            topConstraint,
            bottomViewConstraint,
        ]

        if let itemView = paymentMethodView as? ListItemView {
            let space = itemView.leftSeparatorInset

            paymentMethodViewSeparator.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(paymentMethodViewSeparator)

            let leading = paymentMethodViewSeparator.leading.constraint(equalTo: paymentMethodView.leading,
                                                                        constant: space)
            self.paymentMethodViewSeparatorLeading = leading

            constraints += [
                leading,
                paymentMethodViewSeparator.trailing.constraint(equalTo: contentView.trailing),
                paymentMethodViewSeparator.top.constraint(equalTo: paymentMethodView.bottom),
            ]
        }

        self.descriptionLabelBottomConstraint?.isActive = false
        self.descriptionLabelBottomConstraint = topConstraint

        if footerView == nil {
            priceViewTopConstraint?.isActive = false
            priceViewTopConstraint = bottomViewConstraint
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func configureFooterView() {
        guard let footerView = footerView else { return }
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.appendStyle(UIView.Styles.heightAsContent)
        contentView.addSubview(footerView)

        let topViewAnchor: YAxisAnchor
        if paymentMethodView != nil {
            topViewAnchor = paymentMethodViewSeparator.bottom
        } else {
            topViewAnchor = contentView.top
        }

        let priceViewTopConstraint = priceView.top.constraint(equalTo: footerView.bottom,
                                                              constant: Space.quadruple)
        let topViewConstraint = footerView.top.constraint(equalTo: topViewAnchor)

        var constraints = [
            footerView.leading.constraint(equalTo: contentView.leading, constant: Space.double),
            contentView.trailing.constraint(equalTo: footerView.trailing, constant: Space.double),
            priceViewTopConstraint,
            topViewConstraint,
        ]

        if let itemView = footerView as? ListItemView {
            let space = itemView.leftSeparatorInset

            footerViewSeparator.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(footerViewSeparator)

            let leading = footerViewSeparator.leading.constraint(equalTo: footerView.leading,
                                                                 constant: space)
            self.footerViewSeparatorLeading = leading

            constraints += [
                leading,
                footerViewSeparator.trailing.constraint(equalTo: contentView.trailing),
                footerViewSeparator.top.constraint(equalTo: footerView.bottom),
            ]
        }

        self.priceViewTopConstraint?.isActive = false
        self.priceViewTopConstraint = priceViewTopConstraint

        if paymentMethodView == nil {
            self.descriptionLabelBottomConstraint?.isActive = false
            self.descriptionLabelBottomConstraint = topViewConstraint
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func configurePriceView() {
        let constraints = [
            priceView.bottomMargin.constraint(equalTo: termsOfServiceTextView.topMargin, constant: -Space.quadruple),
            termsOfServiceTextView.bottomMargin.constraint(equalTo: contentView.bottomMargin),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func configureFeeView() {
        contentView.addSubview(feeView)

        let constraints = [
            feeView.topMargin.constraint(equalTo: priceView.bottom, constant: Space.single),
            feeView.bottomMargin.constraint(equalTo: termsOfServiceTextView.topMargin, constant: -Space.quadruple),
            feeView.leadingMargin.constraint(equalTo: contentView.leadingMargin, constant: Space.single),
            feeView.trailingMargin.constraint(equalTo: contentView.trailingMargin, constant: -Space.single),
            termsOfServiceTextView.bottomMargin.constraint(equalTo: contentView.bottomMargin),
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ContractTemplate: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === viewTapGestureRecognizer,
              touch.view is UIControl else {
            return true
        }
        return false
    }
}

// MARK: - UITextViewDelegate

extension ContractTemplate: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange) -> Bool {
        output?.didTapTermsOfService(URL)
        return false
    }
}

// MARK: - ContractTemplateViewInput

extension ContractTemplate: ContractTemplateViewInput {
    func setShopName(_ shopName: String) {
        self.shopName = shopName
    }

    func setPurchaseDescription(_ purchaseDescription: String) {
        self.purchaseDescription = purchaseDescription
    }

    func setPrice(_ price: PriceViewModel) {
        self.price = price
    }

    func setFee(_ fee: PriceViewModel?) {
        self.fee = fee
    }

    func setSubmitButtonEnabled(_ isEnabled: Bool) {
        submitButton.isEnabled = isEnabled
    }

    func setTermsOfService(text: String, hyperlink: String, url: URL) {
        let attributedText: NSMutableAttributedString

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.dynamicCaption1,
            .foregroundColor: UIColor.doveGray,
        ]
        attributedText = NSMutableAttributedString(string: "\(text) ", attributes: attributes)

        let linkAttributedText = NSMutableAttributedString(string: hyperlink, attributes: attributes)
        let linkRange = NSRange(location: 0, length: hyperlink.count)
        linkAttributedText.addAttribute(.link, value: url, range: linkRange)
        attributedText.append(linkAttributedText)

        termsOfServiceTextView.attributedText = attributedText
    }
}

// MARK: - Localized
private extension ContractTemplate {
    enum Localized: String {
        case `continue` = "Contract.next"
        case price = "Contract.price"
        case fee = "Contract.fee"
    }
}
