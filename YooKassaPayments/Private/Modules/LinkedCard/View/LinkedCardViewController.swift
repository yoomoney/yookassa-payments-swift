import UIKit

final class LinkedCardViewController: UIViewController, PlaceholderProvider {
    
    // MARK: - VIPER
    
    var output: LinkedCardViewOutput!
    
    // MARK: - Touches, Presses, and Gestures

    private lazy var viewTapGestureRecognizer: UITapGestureRecognizer = {
        $0.delegate = self
        return $0
    }(UITapGestureRecognizer(
        target: self,
        action: #selector(viewTapGestureRecognizerHandle)
    ))
    
    // MARK: - UI properties
    
    private lazy var scrollView: UIScrollView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.keyboardDismissMode = .interactive
        return $0
    }(UIScrollView())

    private lazy var contentView: UIView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())
    
    private lazy var contentStackView: UIStackView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        return $0
    }(UIStackView())
    
    private lazy var orderView: OrderView = {
        $0.setStyles(UIView.Styles.grayBackground)
        return $0
    }(OrderView())
    
    private lazy var cardView: UIView = {
        $0.setStyles(
            UIView.Styles.grayBackground
        )
        return $0
    }(UIView())
    
    private lazy var maskedCardView: MaskedCardView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.setStyles(
            UIView.Styles.grayBackground,
            UIView.Styles.roundedShadow
        )
        $0.hintCardCode = §Localized.hintCardCode
        $0.hintCardNumber = §Localized.hintCardNumber
        $0.cardCodePlaceholder = §Localized.cvc
        $0.delegate = self
        return $0
    }(MaskedCardView())
    
    private lazy var errorCscView: UIView = {
        $0.setStyles(
            UIView.Styles.grayBackground
        )
        return $0
    }(UIView())
    
    private lazy var errorCscLabel: UILabel = {
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = §Localized.errorCvc
        $0.setStyles(
            UIView.Styles.grayBackground,
            UILabel.DynamicStyle.caption1,
            UILabel.ColorStyle.alert
        )
        return $0
    }(UILabel())
    
    private lazy var actionButtonStackView: UIStackView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.spacing = Space.double
        return $0
    }(UIStackView())
    
    private lazy var submitButton: Button = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.setStyles(
            UIButton.DynamicStyle.primary,
            UIView.Styles.heightAsContent
        )
        $0.setStyledTitle(§Localized.continue, for: .normal)
        $0.addTarget(
            self,
            action: #selector(didPressActionButton),
            for: .touchUpInside
        )
        return $0
    }(Button(type: .custom))
    
    private lazy var termsOfServiceLinkedTextView: LinkedTextView = {
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
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentView = self.actionTitleTextDialog
        return $0
    }(PlaceholderView())

    lazy var actionTitleTextDialog: ActionTitleTextDialog = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.setStyles(ActionTitleTextDialog.Styles.fail)
        $0.buttonTitle = §Localized.PlaceholderView.buttonTitle
        $0.text = §Localized.PlaceholderView.text
        $0.delegate = output
        return $0
    }(ActionTitleTextDialog())
    
    // MARK: - Switcher save auth in app
    
    private lazy var saveAuthInAppSwitchItemView: SwitchItemView = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.layoutMargins = UIEdgeInsets(
            top: Space.double,
            left: Space.double,
            bottom: Space.double,
            right: Space.double
        )
        $0.state = true
        $0.setStyles(SwitchItemView.Styles.primary)
        $0.title = §Localized.saveAuthInAppTitle
        $0.delegate = self
        return $0
    }(SwitchItemView())
    
    private lazy var saveAuthInAppSectionHeaderView: SectionHeaderView = {
        $0.layoutMargins = UIEdgeInsets(
            top: Space.single / 2,
            left: Space.double,
            bottom: Space.double,
            right: Space.double
        )
        $0.title = §Localized.saveAuthInApp
        $0.setStyles(SectionHeaderView.Styles.footer)
        return $0
    }(SectionHeaderView())
    
    // MARK: - Input Presenter
    
    private struct CscInputPresenterStyle: InputPresenterStyle {
        func removedFormatting(from string: String) -> String {
            return string.components(separatedBy: removeFormattingCharacterSet).joined()
        }

        func appendedFormatting(to string: String) -> String {
            return string.map { _ in "•" }.joined()
        }

        var maximalLength: Int {
            return 4
        }

        private let removeFormattingCharacterSet: CharacterSet = {
            var set = CharacterSet.decimalDigits
            set.insert(charactersIn: "•")
            return set.inverted
        }()
    }
    
    private lazy var cvcTextInputPresenter: InputPresenter = {
        let cvcTextStyle = CscInputPresenterStyle()
        let cvcTextInputPresenter = InputPresenter(textInputStyle: cvcTextStyle)
        cvcTextInputPresenter.output = maskedCardView.cardCodeTextView
        return cvcTextInputPresenter
    }()
    
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
            cardView,
            errorCscView,
        ].forEach(contentStackView.addArrangedSubview)
        
        [
            maskedCardView,
        ].forEach(cardView.addSubview)
        
        [
            errorCscLabel,
        ].forEach(errorCscView.addSubview)
        
        [
            submitButton,
            termsOfServiceLinkedTextView,
        ].forEach(actionButtonStackView.addArrangedSubview)
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
        
        scrollViewHeightConstraint.priority = .defaultLow
        
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
            
            maskedCardView.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: Space.double
            ),
            maskedCardView.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: Space.double
            ),
            maskedCardView.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -Space.double
            ),
            maskedCardView.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -Space.double
            ),
            
            errorCscLabel.topAnchor.constraint(equalTo: errorCscView.topAnchor),
            errorCscLabel.leadingAnchor.constraint(
                equalTo: errorCscView.leadingAnchor,
                constant: Space.double
            ),
            errorCscLabel.bottomAnchor.constraint(equalTo: errorCscView.bottomAnchor),
            errorCscLabel.trailingAnchor.constraint(
                equalTo: errorCscView.trailingAnchor,
                constant: -Space.double
            ),
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
    
    // MARK: - Private logic helpers

    private var cachedCvc = ""
}

// MARK: - LinkedCardViewInput

extension LinkedCardViewController: LinkedCardViewInput {
    func endEditing(_ force: Bool) {
        view.endEditing(force)
    }
    
    func setupTitle(
        _ title: String?
    ) {
        navigationItem.title = title ?? §Localized.title
    }
    
    func setupViewModel(
        _ viewModel: LinkedCardViewModel
    ) {
        orderView.title = viewModel.shopName
        orderView.subtitle = viewModel.description
        orderView.value = makePrice(viewModel.price)
        if let fee = viewModel.fee {
            orderView.subvalue = "\(§Localized.fee) " + makePrice(fee)
        } else {
            orderView.subvalue = nil
        }
        
        maskedCardView.cardNumber = viewModel.cardMask
        maskedCardView.cardLogo = viewModel.cardLogo
        
        termsOfServiceLinkedTextView.attributedText = makeTermsOfService(
            viewModel.terms,
            font: UIFont.dynamicCaption2,
            foregroundColor: UIColor.AdaptiveColors.secondary
        )
        termsOfServiceLinkedTextView.textAlignment = .center
    }
    
    func setSaveAuthInAppSwitchItemView() {
        [
            saveAuthInAppSwitchItemView,
            saveAuthInAppSectionHeaderView,
        ].forEach(contentStackView.addArrangedSubview)
    }
    
    func setConfirmButtonEnabled(
        _ isEnabled: Bool
    ) {
        submitButton.isEnabled = isEnabled
    }
    
    func showPlaceholder(
        with message: String
    ) {
        actionTitleTextDialog.title = message
        showPlaceholder()
    }
    
    func setCardState(
        _ state: MaskedCardView.CscState
    ) {
        maskedCardView.cscState = state
        errorCscLabel.isHidden = state != .error
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
}

// MARK: - ActivityIndicatorFullViewPresenting

extension LinkedCardViewController: ActivityIndicatorFullViewPresenting {
    func showActivity() {
        showFullViewActivity(style: ActivityIndicatorView.Styles.heavyLight)
    }

    func hideActivity() {
        hideFullViewActivity()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension LinkedCardViewController: UIGestureRecognizerDelegate {
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

// MARK: - MaskedCardViewDelegate

extension LinkedCardViewController: MaskedCardViewDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let replacementText = cachedCvc.count < cvcTextInputPresenter.style.maximalLength
            ? string
            : ""
        let cvc = (cachedCvc as NSString).replacingCharacters(in: range, with: replacementText)
        cachedCvc = cvcTextInputPresenter.style.removedFormatting(from: cvc)
        cvcTextInputPresenter.input(
            changeCharactersIn: range,
            replacementString: string,
            currentString: textField.text ?? ""
        )
        output.didSetCsc(cachedCvc)
        return false
    }
    
    func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        setCardState(.selected)
    }
    
    func textFieldDidEndEditing(
        _ textField: UITextField
    ) {
        output?.endEditing()
    }
}

// MARK: - UITextViewDelegate

extension LinkedCardViewController: UITextViewDelegate {
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

// MARK: - SwitchItemViewOutput

extension LinkedCardViewController: SwitchItemViewOutput {
    func switchItemView(
        _ itemView: SwitchItemViewInput,
        didChangeState state: Bool
    ) {
        switch itemView {
        case _ where itemView === saveAuthInAppSwitchItemView:
            output?.didChangeSaveAuthInAppState(state)
        default:
            assertionFailure("Unsupported itemView")
        }
    }
}

// MARK: - Localized

private extension LinkedCardViewController {
    enum Localized: String {
        case title = "LinkedCard.title"
        case `continue` = "Contract.next"
        case fee = "Contract.fee"
        case saveAuthInApp = "LinkedCard.saveAuthInApp"
        case saveAuthInAppTitle = "LinkedCard.saveAuthInApp.title"
        
        case hintCardNumber = "BankCardView.inputPanHint"
        case hintCardCode = "BankCardDataInput.hintCardCode"
        case cvc = "BankCardDataInput.cvc"
        case errorCvc = "BankCardDataInput.errorCvc"
        
        enum PlaceholderView: String {
            case buttonTitle = "Common.PlaceholderView.buttonTitle"
            case text = "Common.PlaceholderView.text"
        }
    }
}
