import UIKit

final class BankCardRepeatViewController: UIViewController, PlaceholderProvider {

    // MARK: - VIPER

    var output: BankCardRepeatViewOutput!

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
        $0.hintCardCode = CommonLocalized.BankCardView.inputCvcHint
        $0.hintCardNumber = CommonLocalized.BankCardView.inputPanHint
        $0.cardCodePlaceholder = CommonLocalized.BankCardView.inputCvcPlaceholder
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
        $0.text = CommonLocalized.BankCardView.BottomHint.invalidCvc
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
        $0.spacing = Space.single
        return $0
    }(UIStackView())

    private lazy var submitButton: Button = {
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

    private lazy var submitButtonContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(submitButton)
        let defaultHeight = submitButton.heightAnchor.constraint(equalToConstant: Space.triple * 2)
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            submitButton.topAnchor.constraint(equalTo: view.topAnchor),
            view.trailingAnchor.constraint(equalTo: submitButton.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: Space.single),
            defaultHeight,
        ])

        return view
    }()

    private let termsOfServiceLinkedTextView: LinkedTextView = {
        let view = LinkedTextView()
        view.tintColor = CustomizationStorage.shared.mainScheme
        view.setStyles(UIView.Styles.grayBackground, UITextView.Styles.linked)
        return view
    }()

    private let safeDealLinkedTextView: LinkedTextView = {
        let view = LinkedTextView()
        view.tintColor = CustomizationStorage.shared.mainScheme
        view.setStyles(UIView.Styles.grayBackground, UITextView.Styles.linked)
        return view
    }()

    private var activityIndicatorView: UIView?

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
        $0.buttonTitle = CommonLocalized.PlaceholderView.buttonTitle
        $0.text = CommonLocalized.PlaceholderView.text
        $0.delegate = output
        return $0
    }(ActionTitleTextDialog())

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

    private lazy var scrollViewHeightConstraint =
        scrollView.heightAnchor.constraint(equalToConstant: 0)

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.grayBackground)
        view.addGestureRecognizer(viewTapGestureRecognizer)
        navigationItem.title = Localized.title

        termsOfServiceLinkedTextView.delegate = self
        safeDealLinkedTextView.delegate = self
        safeDealLinkedTextView.isHidden = true
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
            submitButtonContainer,
            termsOfServiceLinkedTextView,
            safeDealLinkedTextView,
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

        scrollViewHeightConstraint.priority = .defaultHigh + 1

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
        let newValue = contentStackView.bounds.height
        if scrollViewHeightConstraint.constant != newValue {
            scrollViewHeightConstraint.constant = newValue
            NotificationCenter.default.post(
                name: .needUpdatePreferredHeight,
                object: nil
            )
        }
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

// MARK: - BankCardRepeatViewInput

extension BankCardRepeatViewController: BankCardRepeatViewInput {
    func endEditing(_ force: Bool) {
        view.endEditing(force)
    }

    func setupViewModel(_ viewModel: BankCardRepeatViewModel) {
        orderView.title = viewModel.shopName
        orderView.subtitle = viewModel.description
        orderView.value = makePrice(viewModel.price)
        if let fee = viewModel.fee {
            orderView.subvalue = "\(CommonLocalized.Contract.fee) " + makePrice(fee)
        } else {
            orderView.subvalue = nil
        }

        maskedCardView.cardNumber = viewModel.cardMask
        maskedCardView.cardLogo = viewModel.cardLogo

        termsOfServiceLinkedTextView.attributedText = viewModel.terms
        safeDealLinkedTextView.attributedText = viewModel.safeDealText
        safeDealLinkedTextView.isHidden = viewModel.safeDealText?.string.isEmpty ?? true
        termsOfServiceLinkedTextView.textAlignment = .center
        safeDealLinkedTextView.textAlignment = .center
    }

    func setConfirmButtonEnabled(
        _ isEnabled: Bool
    ) {
        submitButton.isEnabled = isEnabled
    }

    func setSavePaymentMethodViewModel(
        _ savePaymentMethodViewModel: SavePaymentMethodViewModel
    ) {
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

    private func makePrice(
        _ price: PriceViewModel
    ) -> String {
        return price.integerPart
             + price.decimalSeparator
             + price.fractionalPart
             + price.currency
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

extension BankCardRepeatViewController: ActivityIndicatorFullViewPresenting {
    func showActivity() {
        guard activityIndicatorView == nil else { return }

        let activityIndicatorView = ActivityIndicatorView()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.activity.startAnimating()
        activityIndicatorView.setStyles(ActivityIndicatorView.Styles.heavyLight)
        view.addSubview(activityIndicatorView)

        self.activityIndicatorView = activityIndicatorView

        let constraints = [
            activityIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicatorView.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: Constants.defaultViewHeight),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func hideActivity() {
        self.activityIndicatorView?.removeFromSuperview()
        self.activityIndicatorView = nil
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BankCardRepeatViewController: UIGestureRecognizerDelegate {
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

extension BankCardRepeatViewController: MaskedCardViewDelegate {
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

extension BankCardRepeatViewController: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange
    ) -> Bool {
        switch textView {
        case termsOfServiceLinkedTextView:
            output?.didTapTermsOfService(URL)
        case safeDealLinkedTextView:
            output?.didTapSafeDealInfo(URL)
        default:
            assertionFailure("Unsupported textView")
        }
        return false
    }
}

// MARK: - LinkedItemViewOutput

extension BankCardRepeatViewController: LinkedItemViewOutput {
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

extension BankCardRepeatViewController: SwitchItemViewOutput {
    func switchItemView(
        _ itemView: SwitchItemViewInput,
        didChangeState state: Bool
    ) {
        switch itemView {
        case _ where itemView === savePaymentMethodSwitchItemView:
            output?.didChangeSavePaymentMethodState(state)
        default:
            assertionFailure("Unsupported itemView")
        }
    }
}

// MARK: - Constants

private extension BankCardRepeatViewController {
    enum Constants {
        static let defaultViewHeight: CGFloat = 300
    }
}

// MARK: - Localized

private extension BankCardRepeatViewController {
    enum Localized {
        static let title = NSLocalizedString(
            "BankCardRepeat.title",
            bundle: Bundle.framework,
            value: "Сохраненная карта",
            comment: "Title `Сохраненная карта` на экране `Сохраненная карта` https://yadi.sk/d/Cyocbh86zUr3cA"
        )
        static let savePaymentMethodTitle = NSLocalizedString(
            "BankCardRepeat.savePaymentMethod.title",
            bundle: Bundle.framework,
            value: "Привязать карту",
            comment: "Текст `Привязать карту` на экране `Сохраненная карта` https://yadi.sk/d/Cyocbh86zUr3cA"
        )
    }
}
