import UIKit

final class PaymentAuthorizationViewController: UIViewController, PlaceholderProvider {

    // MARK: - VIPER

    var output: PaymentAuthorizationViewOutput!

    // MARK: - UI properties

    private lazy var shouldShowTitleOnNavBar: Bool = {
        return UIScreen.main.isShort
    }()

    private lazy var titleLabel: UILabel = {
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.styledText = Localized.smsCodePlaceholder
        $0.setStyles(
            UILabel.DynamicStyle.title1,
            UILabel.Styles.multiline
        )
        return $0
    }(UILabel())

    private lazy var codeControl: FixedLengthCodeControl = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        return $0
    }(FixedLengthCodeControl())

    private lazy var codeErrorLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setStyles(
            UILabel.DynamicStyle.caption2,
            UILabel.ColorStyle.alert,
            UILabel.Styles.alignCenter,
            UILabel.Styles.multiline
        )
        return $0
    }(UILabel())

    private lazy var descriptionLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setStyles(
            UILabel.DynamicStyle.body,
            UILabel.ColorStyle.secondary,
            UILabel.Styles.alignCenter,
            UILabel.Styles.multiline
        )
        return $0
    }(UILabel())

    private lazy var resendCodeButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.setStyles(UIButton.DynamicStyle.link)
        $0.addTarget(
            self,
            action: #selector(resendCodeButtonDidPress),
            for: .touchUpInside
        )
        return $0
    }(UIButton(type: .custom))

    // MARK: - PlaceholderProvider

    lazy var placeholderView: PlaceholderView = {
        $0.setStyles(UIView.Styles.defaultBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentView = self.actionTitleTextDialog
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
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

    // MARK: - Constraints

    private lazy var descriptionLabelTopConstraint = descriptionLabel.topAnchor.constraint(
        equalTo: codeErrorLabel.bottomAnchor,
        constant: Space.double
    )

    private lazy var resendButtonBottomConstraint = view.layoutMarginsGuide.bottomAnchor.constraint(
        equalTo: resendCodeButton.bottomAnchor,
        constant: Space.triple * 2
    )

    private lazy var placeholderViewBottomConstraint = placeholderView.bottomAnchor.constraint(
        equalTo: view.layoutMarginsGuide.topAnchor,
        constant: -Space.fivefold
    )

    // MARK: - Managing the View

    private lazy var defaultViewHeight = view.heightAnchor.constraint(equalToConstant: 320)

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.grayBackground)

        defaultViewHeight.priority = .defaultHigh + 1
        defaultViewHeight.isActive = true

        setupView()
        setupConstraints()

        if shouldShowTitleOnNavBar {
            navigationItem.title = Localized.smsCodePlaceholder
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appendKeyboardObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
            _ = self?.codeControl.becomeFirstResponder()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardObservers()
        super.viewWillDisappear(animated)
    }

    // MARK: - Setup

    private func setupView() {
        if !shouldShowTitleOnNavBar {
            view.addSubview(titleLabel)
        }

        [
            codeControl,
            codeErrorLabel,
            descriptionLabel,
            resendCodeButton,
            placeholderView,
        ].forEach(view.addSubview)
    }

    private func setupConstraints() {
        let topConstraint: NSLayoutConstraint
        if shouldShowTitleOnNavBar {
            defaultViewHeight.constant = 220
        }
        if #available(iOS 11.0, *) {
            if shouldShowTitleOnNavBar {
                topConstraint = codeControl.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: Space.double
                )
            } else {
                topConstraint = titleLabel.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: Space.single / 4
                )

                codeControl.topAnchor.constraint(
                    equalTo: titleLabel.bottomAnchor,
                    constant: Space.quadruple
                ).isActive = true
            }

            resendButtonBottomConstraint = resendCodeButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Space.quadruple
            )
            placeholderViewBottomConstraint = placeholderView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        } else {
            if shouldShowTitleOnNavBar {
                topConstraint = codeControl.topAnchor.constraint(
                    equalTo: view.layoutMarginsGuide.topAnchor,
                    constant: Space.double
                )
            } else {
                topConstraint = titleLabel.topAnchor.constraint(
                    equalTo: view.layoutMarginsGuide.topAnchor,
                    constant: Space.single / 4
                )
                codeControl.topAnchor.constraint(
                    equalTo: titleLabel.bottomAnchor,
                    constant: Space.quadruple
                ).isActive = true
            }

            resendButtonBottomConstraint = resendCodeButton.bottomAnchor.constraint(
                equalTo: view.layoutMarginsGuide.bottomAnchor,
                constant: -Space.quadruple
            )
            placeholderViewBottomConstraint = placeholderView.bottomAnchor.constraint(
                equalTo: view.layoutMarginsGuide.bottomAnchor
            )
        }

        var constraints = [
            topConstraint,
            codeControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            codeErrorLabel.topAnchor.constraint(
                equalTo: codeControl.bottomAnchor,
                constant: Space.single
            ),
            codeErrorLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Space.double
            ),
            codeErrorLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Space.double
            ),

            descriptionLabelTopConstraint,
            descriptionLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Space.double
            ),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Space.double
            ),

            resendCodeButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Space.double
            ),
            resendCodeButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Space.double
            ),
            resendButtonBottomConstraint,
            resendCodeButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: Space.single),

            placeholderView.topAnchor.constraint(equalTo: view.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placeholderViewBottomConstraint,
        ]

        if !shouldShowTitleOnNavBar {
            constraints += [
                titleLabel.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: Space.double
                ),
                titleLabel.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -Space.double
                ),
            ]
        }

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions

    @objc
    func resendCodeButtonDidPress(_ sender: UIButton) {
        output.didPressResendCode()
    }
}

// MARK: - KeyboardObserving

extension PaymentAuthorizationViewController: KeyboardObserver {
    func keyboardWillShow(with keyboardInfo: KeyboardNotificationInfo) {
        updateBottomConstraint(keyboardInfo)
    }

    func keyboardWillHide(with keyboardInfo: KeyboardNotificationInfo) {
        updateBottomConstraint(keyboardInfo)
    }

    func keyboardDidShow(with keyboardInfo: KeyboardNotificationInfo) {
        view.setNeedsUpdateConstraints()
    }
    func keyboardDidHide(with keyboardInfo: KeyboardNotificationInfo) {}
    func keyboardDidUpdateFrame(_ keyboardFrame: CGRect) {}

    private func updateBottomConstraint(
        _ keyboardInfo: KeyboardNotificationInfo
    ) {
        let duration = keyboardInfo.animationDuration ?? 0.3

        var options: UIView.AnimationOptions = []
        if let animationCurve = keyboardInfo.animationCurve {
            options = UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue))
        }

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

// MARK: - PlaceholderPresenting

extension PaymentAuthorizationViewController: PlaceholderPresenting {
    func showPlaceholder() {
        placeholderView.isHidden = false
    }

    func hidePlaceholder() {
        placeholderView.isHidden = true
    }
}

// MARK: - PaymentAuthorizationViewInput

extension PaymentAuthorizationViewController: PaymentAuthorizationViewInput {
    func endEditing() {
        view.endEditing(true)
        codeControl.setIsEditable(false)
    }

    func setCodeLength(_ length: Int) {
        codeControl.setLength(length)
    }

    func clearCode() {
        codeControl.clear()
        codeControl.setIsEditable(true)
        _ = codeControl.becomeFirstResponder()
    }

    func setCodeError(_ error: String?) {
        codeErrorLabel.styledText = error
    }

    func setDescription(_ description: String) {
        descriptionLabel.styledText = description
        descriptionLabel.setStyles(
            UILabel.DynamicStyle.body,
            UILabel.ColorStyle.secondary,
            UILabel.Styles.alignCenter,
            UILabel.Styles.multiline
        )
    }

    func setDescriptionError(_ description: String) {
        descriptionLabel.styledText = description
        descriptionLabel.setStyles(UILabel.ColorStyle.alert)
    }

    func setRemainingTimeText(_ text: String) {
        resendCodeButton.setStyledTitle(text, for: .disabled)
    }

    func setResendCodeButtonTitle(_ title: String) {
        resendCodeButton.setStyledTitle(title, for: .normal)
    }

    func setResendCodeButtonIsEnabled(_ isEnabled: Bool) {
        resendCodeButton.isEnabled = isEnabled
    }

    func setResendCodeButtonHidden(_ isHidden: Bool) {
        resendCodeButton.isHidden = true
    }

    func showPlaceholder(title: String) {
        actionTitleTextDialog.title = title
        showPlaceholder()
    }
}

// MARK: - FixedLengthCodeControlDelegate

extension PaymentAuthorizationViewController: FixedLengthCodeControlDelegate {
    func fixedLengthCodeControl(
        _ fixedLengthCodeControl: FixedLengthCodeControl,
        didGetCode code: String
    ) {
        output.didGetCode(code)
    }
}

// MARK: - ActivityIndicatorPresenting

extension PaymentAuthorizationViewController {
    func showActivity() {
        codeControl.setIsEditable(false)
        showFullViewActivity(style: ActivityIndicatorView.Styles.heavyLight)
    }

    func hideActivity() {
        hideFullViewActivity()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) { [weak self] in
            self?.codeControl.clear()
        }
    }
}

// MARK: - ActivityIndicatorFullViewPresenting

extension PaymentAuthorizationViewController: ActivityIndicatorFullViewPresenting {}

// MARK: - Localized

private extension PaymentAuthorizationViewController {
    enum Localized {
        static let smsCodePlaceholder = NSLocalizedString(
            "Contract.placeholder.smsCode",
            bundle: Bundle.framework,
            value: "Введите код из смс",
            comment: ""
        )
    }
}
