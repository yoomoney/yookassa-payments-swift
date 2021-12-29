import UIKit

final class BankCardViewController: UIViewController {

    // MARK: - VIPER

    var output: BankCardViewOutput!

    private var cachedCvc = ""

    private lazy var cvcTextInputPresenter: InputPresenter = {
        let cvcTextStyle = CscInputPresenterStyle()
        let cvcTextInputPresenter = InputPresenter(textInputStyle: cvcTextStyle)
        cvcTextInputPresenter.output = maskedCardView.cardCodeTextView
        return cvcTextInputPresenter
    }()

    // MARK: - Touches, Presses, and Gestures

    private lazy var viewTapGestureRecognizer: UITapGestureRecognizer = {
        $0.delegate = self
        return $0
    }(UITapGestureRecognizer(
        target: self,
        action: #selector(viewTapGestureRecognizerHandle)
    ))

    // MARK: - UI properties

    var bankCardDataInputView: BankCardDataInputView!

    private lazy var maskedCardView: MaskedCardView = {
        let view = MaskedCardView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = CustomizationStorage.shared.mainScheme
        view.setStyles(UIView.Styles.grayBackground, UIView.Styles.roundedShadow)
        view.hintCardCode = CommonLocalized.BankCardView.inputCvcHint
        view.hintCardNumber = CommonLocalized.BankCardView.inputPanHint
        view.cardCodePlaceholder = CommonLocalized.BankCardView.inputCvcPlaceholder
        view.delegate = self
        return view
    }()

    private lazy var errorCscView: UIView = {
        let view = UIView(frame: .zero)
        view.setStyles(UIView.Styles.grayBackground)
        return view
    }()

    private lazy var errorCscLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = CommonLocalized.BankCardView.BottomHint.invalidCvc
        view.setStyles(
            UIView.Styles.grayBackground,
            UILabel.DynamicStyle.caption1,
            UILabel.ColorStyle.alert
        )
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.keyboardDismissMode = .interactive
        return $0
    }(UIScrollView())

    private lazy var contentStackView: UIStackView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        return $0
    }(UIStackView())

    private lazy var contentView: UIView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    private lazy var orderView: OrderView = {
        $0.setStyles(UIView.Styles.grayBackground)
        return $0
    }(OrderView())

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
            action: #selector(didPressSubmitButton),
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
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.tintColor = CustomizationStorage.shared.mainScheme
        view.setStyles(UIView.Styles.grayBackground, UITextView.Styles.linked)
        return view
    }()

    private let safeDealLinkedTextView: LinkedTextView = {
        let view = LinkedTextView()
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        view.tintColor = CustomizationStorage.shared.mainScheme
        view.setStyles(UIView.Styles.grayBackground, UITextView.Styles.linked)
        return view
    }()

    // MARK: - Constraints

    private lazy var scrollViewHeightConstraint: NSLayoutConstraint = {
        let constraint = scrollView.heightAnchor.constraint(equalToConstant: 0)
        constraint.priority = .defaultHigh + 1
        return constraint
    }()

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

    // MARK: - SetupView

    private func setupView() {
        errorCscView.addSubview(errorCscLabel)

        [scrollView, actionButtonStackView].forEach(view.addSubview)

        scrollView.addSubview(contentView)
        [contentStackView].forEach(contentView.addSubview)

        [
            orderView,
            bankCardDataInputView,
            maskedCardView,
            errorCscView,
        ].forEach(contentStackView.addArrangedSubview)

        if #available(iOS 11, *) {
            contentStackView.setCustomSpacing(Space.double, after: maskedCardView)
        }

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

            bankCardDataInputView.heightAnchor.constraint(lessThanOrEqualToConstant: 126),

            maskedCardView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor, constant: Space.double),
            contentStackView.trailingAnchor.constraint(equalTo: maskedCardView.trailingAnchor, constant: Space.double),

            errorCscLabel.topAnchor.constraint(equalTo: errorCscView.topAnchor),
            errorCscLabel.bottomAnchor.constraint(equalTo: errorCscView.bottomAnchor),
            errorCscLabel.leadingAnchor.constraint(equalTo: errorCscView.leadingAnchor, constant: Space.double),
            errorCscView.trailingAnchor.constraint(equalTo: errorCscLabel.trailingAnchor, constant: Space.double),
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Configuring the View’s Layout Behavior

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.updateContentHeight()
        }
    }

    private func updateContentHeight() {
        scrollViewHeightConstraint.constant = ceil(scrollView.contentSize.height) + Space.triple * 2
    }
}

// MARK: - BankCardViewInput

extension BankCardViewController: BankCardViewInput {
    func setViewModel(_ viewModel: BankCardViewModel) {
        orderView.title = viewModel.shopName
        orderView.subtitle = viewModel.description
        orderView.value = viewModel.priceValue
        orderView.subvalue = viewModel.feeValue
        termsOfServiceLinkedTextView.attributedText = viewModel.termsOfService
        safeDealLinkedTextView.isHidden = viewModel.safeDealText?.string.isEmpty ?? true
        safeDealLinkedTextView.attributedText = viewModel.safeDealText
        termsOfServiceLinkedTextView.textAlignment = .center
        safeDealLinkedTextView.textAlignment = .center
        viewModel.paymentOptionTitle.map { navigationItem.title = $0 }

        if viewModel.instrumentMode {
            bankCardDataInputView.isHidden = true
            maskedCardView.isHidden = false
            errorCscView.isHidden = false
        } else {
            bankCardDataInputView.isHidden = false
            maskedCardView.isHidden = true
            errorCscView.isHidden = true
        }

        maskedCardView.cardNumber = viewModel.maskedNumber
        maskedCardView.cardLogo = viewModel.cardLogo

        if
            let view = viewModel.recurrencyAndDataSavingSection,
            let index = contentStackView.arrangedSubviews.firstIndex(of: maskedCardView)
        {
            contentStackView.insertArrangedSubview(view, at: contentStackView.arrangedSubviews.index(after: index))
        }
    }

    func setSubmitButtonEnabled(
        _ isEnabled: Bool
    ) {
        submitButton.isEnabled = isEnabled
    }

    func endEditing(
        _ force: Bool
    ) {
        view.endEditing(force)
    }

    func setBackBarButtonHidden(_ isHidden: Bool) {
        navigationItem.hidesBackButton = isHidden
    }
}

// MARK: - ActivityIndicatorFullViewPresenting

extension BankCardViewController: ActivityIndicatorFullViewPresenting {
    func showActivity() {
        showFullViewActivity(style: ActivityIndicatorView.Styles.heavyLight)
    }

    func hideActivity() {
        hideFullViewActivity()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BankCardViewController: UIGestureRecognizerDelegate {
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

extension BankCardViewController: UITextViewDelegate {
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

// MARK: - Actions

@objc
private extension BankCardViewController {
    @objc
    private func didPressSubmitButton(
        _ sender: UIButton
    ) {
        output?.didPressSubmitButton()
    }

    @objc
    private func viewTapGestureRecognizerHandle(
        _ gestureRecognizer: UITapGestureRecognizer
    ) {
        guard gestureRecognizer.state == .recognized else { return }
        view.endEditing(true)
    }
}

// MARK: - MaskedCardViewDelegate

extension BankCardViewController: MaskedCardViewDelegate {
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

    func setCardState(_ state: MaskedCardView.CscState) {
        maskedCardView.cscState = state
        errorCscLabel.isHidden = state != .error
    }
}

// MARK: - Localized

private extension BankCardViewController {
    enum Localized {
        static let title = NSLocalizedString(
            "BankCardDataInput.navigationBarTitle",
            bundle: Bundle.framework,
            value: "Банковская карта",
            comment: "Title `Банковская карта` на экране `Банковская карта` https://yadi.sk/i/Z2oi1Uun7nS-jA"
        )
        static let savePaymentMethodTitle = NSLocalizedString(
            "BankCard.savePaymentMethod.title",
            bundle: Bundle.framework,
            value: "Привязать карту",
            comment: "Текст `Привязать карту` на экране `Банковская карта` https://yadi.sk/i/Z2oi1Uun7nS-jA"
        )
    }
}
