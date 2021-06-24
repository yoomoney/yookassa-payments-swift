import UIKit

final class YooMoneyViewController: UIViewController, PlaceholderProvider {

    // MARK: - VIPER

    var output: YooMoneyViewOutput!

    // MARK: - Touches, Presses, and Gestures

    private lazy var viewTapGestureRecognizer: UITapGestureRecognizer = {
        $0.delegate = self
        return $0
    }(UITapGestureRecognizer(
        target: self,
        action: #selector(viewTapGestureRecognizerHandle)
    ))

    // MARK: - UI properties

    fileprivate lazy var scrollView: UIScrollView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.keyboardDismissMode = .interactive
        return $0
    }(UIScrollView())

    fileprivate lazy var contentView: UIView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    fileprivate lazy var contentStackView: UIStackView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        return $0
    }(UIStackView())

    fileprivate lazy var orderView: OrderView = {
        $0.setStyles(UIView.Styles.grayBackground)
        return $0
    }(OrderView())

    fileprivate lazy var paymentMethodView: LargeIconButtonItemView = {
        $0.setStyles(
            UIView.Styles.grayBackground,
            LargeIconButtonItemView.Styles.secondary
        )
        return $0
    }(LargeIconButtonItemView())

    fileprivate lazy var actionButtonStackView: UIStackView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.spacing = Space.double
        return $0
    }(UIStackView())

    fileprivate lazy var submitButton: Button = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.setStyles(
            UIButton.DynamicStyle.primary,
            UIView.Styles.heightAsContent
        )
        $0.setStyledTitle(CommonLocalized.Contract.next, for: .normal)
        $0.addTarget(
            self,
            action: #selector(didPressActionButton),
            for: .touchUpInside
        )
        return $0
    }(Button(type: .custom))

    fileprivate lazy var termsOfServiceLinkedTextView: LinkedTextView = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.setStyles(
            UIView.Styles.grayBackground,
            UITextView.Styles.linked
        )
        $0.delegate = self
        return $0
    }(LinkedTextView())

    // MARK: - PlaceholderProvider

    lazy var placeholderView: PlaceholderView = {
        $0.setStyles(UIView.Styles.defaultBackground)
        $0.contentView = self.actionTitleTextDialog
        return $0
    }(PlaceholderView())

    lazy var actionTitleTextDialog: ActionTitleTextDialog = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.setStyles(ActionTitleTextDialog.Styles.fail)
        $0.buttonTitle = CommonLocalized.PlaceholderView.buttonTitle
        $0.text = CommonLocalized.PlaceholderView.text
        $0.delegate = output
        return $0
    }(ActionTitleTextDialog())

    // MARK: - Separator

    fileprivate lazy var separator: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setStyles(UIView.Styles.separator)
        return $0
    }(UIView())

    fileprivate lazy var separatorView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    // MARK: - Switcher save auth in app

    fileprivate lazy var saveAuthInAppSwitchItemView: SwitchItemView = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.layoutMargins = UIEdgeInsets(
            top: Space.double,
            left: Space.double,
            bottom: Space.double,
            right: Space.double
        )
        $0.state = true
        $0.setStyles(SwitchItemView.Styles.primary)
        $0.title = CommonLocalized.SaveAuthInApp.title
        $0.delegate = self
        return $0
    }(SwitchItemView())

    fileprivate lazy var saveAuthInAppSectionHeaderView: SectionHeaderView = {
        $0.layoutMargins = UIEdgeInsets(
            top: Space.single / 2,
            left: Space.double,
            bottom: Space.double,
            right: Space.double
        )
        $0.title = CommonLocalized.SaveAuthInApp.text
        $0.setStyles(SectionHeaderView.Styles.footer)
        return $0
    }(SectionHeaderView())

    // MARK: - Switch save payment method UI Properties

    fileprivate lazy var savePaymentMethodSwitchItemView: SwitchItemView = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.layoutMargins = UIEdgeInsets(
            top: Space.double,
            left: Space.double,
            bottom: Space.double,
            right: Space.double
        )
        $0.setStyles(SwitchItemView.Styles.primary)
        $0.title = Localized.savePaymentMethodTitle
        $0.delegate = self
        return $0
    }(SwitchItemView())

    fileprivate lazy var savePaymentMethodSwitchLinkedItemView: LinkedItemView = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.layoutMargins = UIEdgeInsets(
            top: Space.single / 2,
            left: Space.double,
            bottom: Space.double,
            right: Space.double
        )
        $0.setStyles(LinkedItemView.Styles.linked)
        $0.delegate = self
        return $0
    }(LinkedItemView())

    // MARK: - Strict save payment method UI Properties

    fileprivate lazy var savePaymentMethodStrictSectionHeaderView: SectionHeaderView = {
        $0.layoutMargins = UIEdgeInsets(
            top: Space.double,
            left: Space.double,
            bottom: 0,
            right: Space.double
        )
        $0.title = Localized.savePaymentMethodTitle
        $0.setStyles(SectionHeaderView.Styles.primary)
        return $0
    }(SectionHeaderView())

    fileprivate lazy var savePaymentMethodStrictLinkedItemView: LinkedItemView = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.layoutMargins = UIEdgeInsets(
            top: Space.single / 4,
            left: Space.double,
            bottom: Space.double,
            right: Space.double
        )
        $0.setStyles(LinkedItemView.Styles.linked)
        $0.delegate = self
        return $0
    }(LinkedItemView())

    // MARK: - Constraints

    private lazy var scrollViewHeightConstraint: NSLayoutConstraint = {
        let constraint = scrollView.heightAnchor.constraint(equalToConstant: 0)
        constraint.priority = .defaultLow
        return constraint
    }()

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.grayBackground)
        view.addGestureRecognizer(viewTapGestureRecognizer)
        navigationItem.title = Localized.title

        setupView()
        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
    }

    // MARK: - Setup

    private func setupView() {
        [
            scrollView,
            actionButtonStackView,
        ].forEach(view.addSubview)

        scrollView.addSubview(contentView)

        [
            contentStackView,
        ].forEach(contentView.addSubview)

        [
            orderView,
            paymentMethodView,
        ].forEach(contentStackView.addArrangedSubview)

        [
            submitButton,
            termsOfServiceLinkedTextView,
        ].forEach(actionButtonStackView.addArrangedSubview)

        [
            separator,
        ].forEach(separatorView.addSubview)
    }

    private func setupConstraints() {
        let bottomConstraint: NSLayoutConstraint
        let topConstraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            bottomConstraint = actionButtonStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Space.double
            )
            topConstraint = scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            )
        } else {
            bottomConstraint = actionButtonStackView.bottomAnchor.constraint(
                equalTo: bottomLayoutGuide.topAnchor,
                constant: -Space.double
            )
            topConstraint = scrollView.topAnchor.constraint(
                equalTo: topLayoutGuide.bottomAnchor
            )
        }

        let constraints = [
            scrollViewHeightConstraint,

            topConstraint,
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: actionButtonStackView.topAnchor,
                constant: -Space.double
            ),

            actionButtonStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Space.double
            ),
            actionButtonStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Space.double
            ),
            bottomConstraint,

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            separator.topAnchor.constraint(equalTo: separatorView.topAnchor),
            separator.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor, constant: Space.double),
            separator.bottomAnchor.constraint(equalTo: separatorView.bottomAnchor),
            separator.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor, constant: -Space.double),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Configuring the View’s Layout Behavior

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.fixTableViewHeight()
        }
    }

    private func fixTableViewHeight() {
        scrollViewHeightConstraint.constant = contentStackView.bounds.height
    }

    // MARK: - Action

    @objc
    private func didPressActionButton(
        _ sender: UIButton
    ) {
        output?.didTapActionButton()
    }

    @objc
    private func viewTapGestureRecognizerHandle(
        _ gestureRecognizer: UITapGestureRecognizer
    ) {
        guard gestureRecognizer.state == .recognized else { return }
        view.endEditing(true)
    }
}

// MARK: - YooMoneyViewInput

extension YooMoneyViewController: YooMoneyViewInput {
    func setupViewModel(
        _ viewModel: YooMoneyViewModel
    ) {
        orderView.title = viewModel.shopName
        orderView.subtitle = viewModel.description
        orderView.value = makePrice(viewModel.price)
        if let fee = viewModel.fee {
            orderView.subvalue = "\(CommonLocalized.Contract.fee) " + makePrice(fee)
        } else {
            orderView.subvalue = nil
        }

        paymentMethodView.title = viewModel.paymentMethod.title
        paymentMethodView.subtitle = viewModel.paymentMethod.subtitle ?? ""
        paymentMethodView.image = UIImage.avatar

        paymentMethodView.rightButtonTitle = Localized.logout
        paymentMethodView.output = self

        termsOfServiceLinkedTextView.attributedText = makeTermsOfService(
            viewModel.terms,
            font: UIFont.dynamicCaption2,
            foregroundColor: UIColor.AdaptiveColors.secondary
        )
        termsOfServiceLinkedTextView.textAlignment = .center
    }

    func setupAvatar(
        _ avatar: UIImage
    ) {
        paymentMethodView.image = avatar.rounded(cornerRadius: Space.fivefold)
    }

    func setSavePaymentMethodViewModel(
        _ savePaymentMethodViewModel: SavePaymentMethodViewModel
    ) {
        if contentStackView.arrangedSubviews.contains(saveAuthInAppSwitchItemView) {
            contentStackView.addArrangedSubview(separatorView)
        }

        switch savePaymentMethodViewModel {
        case .switcher(let viewModel):
            savePaymentMethodSwitchItemView.state = viewModel.state
            savePaymentMethodSwitchLinkedItemView.attributedString = makeSavePaymentMethodAttributedString(
                text: viewModel.text,
                hyperText: viewModel.hyperText,
                font: UIFont.dynamicCaption1,
                foregroundColor: UIColor.AdaptiveColors.secondary
            )
            [
                savePaymentMethodSwitchItemView,
                savePaymentMethodSwitchLinkedItemView,
            ].forEach(contentStackView.addArrangedSubview)

        case .strict(let viewModel):
            savePaymentMethodStrictLinkedItemView.attributedString = makeSavePaymentMethodAttributedString(
                text: viewModel.text,
                hyperText: viewModel.hyperText,
                font: UIFont.dynamicCaption1,
                foregroundColor: UIColor.AdaptiveColors.secondary
            )
            [
                savePaymentMethodStrictSectionHeaderView,
                savePaymentMethodStrictLinkedItemView,
            ].forEach(contentStackView.addArrangedSubview)
        }
    }

    func setSaveAuthInAppSwitchItemView() {
        [
            saveAuthInAppSwitchItemView,
            saveAuthInAppSectionHeaderView,
        ].forEach(contentStackView.addArrangedSubview)
    }

    func showPlaceholder(
        with message: String
    ) {
        actionTitleTextDialog.title = message
        showPlaceholder()
    }

    func setBackBarButtonHidden(
        _ isHidden: Bool
    ) {
        navigationItem.hidesBackButton = isHidden
    }

    private func makePrice(
        _ price: PriceViewModel
    ) -> String {
        return price.integerPart
             + price.decimalSeparator
             + price.fractionalPart
             + price.currency
    }

    private func makeTermsOfService(
        _ terms: TermsOfService,
        font: UIFont,
        foregroundColor: UIColor
    ) -> NSMutableAttributedString {
        let attributedText: NSMutableAttributedString

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: foregroundColor,
        ]
        attributedText = NSMutableAttributedString(
            string: "\(terms.text) ",
            attributes: attributes
        )

        let linkAttributedText = NSMutableAttributedString(
            string: terms.hyperlink,
            attributes: attributes
        )
        let linkRange = NSRange(location: 0, length: terms.hyperlink.count)
        linkAttributedText.addAttribute(.link, value: terms.url, range: linkRange)
        attributedText.append(linkAttributedText)

        return attributedText
    }

    private func makeSavePaymentMethodAttributedString(
        text: String,
        hyperText: String,
        font: UIFont,
        foregroundColor: UIColor
    ) -> NSAttributedString {
        let attributedText: NSMutableAttributedString
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: foregroundColor,
        ]
        attributedText = NSMutableAttributedString(string: "\(text) ", attributes: attributes)

        let linkAttributedText = NSMutableAttributedString(string: hyperText, attributes: attributes)
        let linkRange = NSRange(location: 0, length: hyperText.count)
        // swiftlint:disable force_unwrapping
        let fakeLink = URL(string: "https://yookassa.ru")!
        // swiftlint:enable force_unwrapping
        linkAttributedText.addAttribute(.link, value: fakeLink, range: linkRange)
        attributedText.append(linkAttributedText)

        return attributedText
    }
}

// MARK: - ActivityIndicatorFullViewPresenting

extension YooMoneyViewController: ActivityIndicatorFullViewPresenting {
    func showActivity() {
        showFullViewActivity(style: ActivityIndicatorView.Styles.heavyLight)
    }

    func hideActivity() {
        hideFullViewActivity()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension YooMoneyViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        guard gestureRecognizer === viewTapGestureRecognizer,
              touch.view is UIControl else {
            return true
        }
        return false
    }
}

// MARK: - UITextViewDelegate

extension YooMoneyViewController: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange
    ) -> Bool {
        switch textView {
        case termsOfServiceLinkedTextView:
            output?.didTapTermsOfService(URL)
        default:
            assertionFailure("Unsupported textView")
        }
        return false
    }
}

// MARK: - LinkedItemViewOutput

extension YooMoneyViewController: LinkedItemViewOutput {
    func didTapOnLinkedView(on itemView: LinkedItemViewInput) {
        switch itemView {
        case _ where itemView === savePaymentMethodSwitchLinkedItemView,
             _ where itemView === savePaymentMethodStrictLinkedItemView:
            output?.didTapOnSavePaymentMethod()
        default:
            assertionFailure("Unsupported itemView")
        }
    }
}

// MARK: - SwitchItemViewOutput

extension YooMoneyViewController: SwitchItemViewOutput {
    func switchItemView(
        _ itemView: SwitchItemViewInput,
        didChangeState state: Bool
    ) {
        switch itemView {
        case _ where itemView === saveAuthInAppSwitchItemView:
            output?.didChangeSaveAuthInAppState(state)
        case _ where itemView === savePaymentMethodSwitchItemView:
            output?.didChangeSavePaymentMethodState(state)
        default:
            assertionFailure("Unsupported itemView")
        }
    }
}

// MARK: - LargeIconButtonItemViewOutput

extension YooMoneyViewController: LargeIconButtonItemViewOutput {
    func didPressRightButton(in itemView: LargeIconButtonItemViewInput) {
        switch itemView {
        case _ where itemView === paymentMethodView:
            output?.didTapLogout()
        default:
            assertionFailure("Unsupported itemView")
        }
    }
}

// MARK: - Localized

private extension YooMoneyViewController {
    enum Localized {
        static let title = NSLocalizedString(
            "YooMoney.title",
            bundle: Bundle.framework,
            value: "ЮMoney",
            comment: "Текст `ЮMoney` https://yadi.sk/i/o89CnEUSmNsM7g"
        )
        static let savePaymentMethodTitle = NSLocalizedString(
            "Wallet.savePaymentMethod.title",
            bundle: Bundle.framework,
            value: "Привязать кошелек",
            comment: "Текст `Привязать кошелек` https://yadi.sk/i/o89CnEUSmNsM7g"
        )
        static let logout = NSLocalizedString(
            "Contract.logout",
            bundle: Bundle.framework,
            value: "Выйти",
            comment: "Текст `Выйти` https://yadi.sk/i/o89CnEUSmNsM7g"
        )
    }
}
