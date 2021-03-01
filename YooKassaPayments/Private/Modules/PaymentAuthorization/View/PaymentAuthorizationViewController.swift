final class PaymentAuthorizationViewController: UIViewController, PlaceholderProvider {
    
    // MARK: - VIPER
    
    var output: PaymentAuthorizationViewOutput!
    
    // MARK: - UI properties
    
    private lazy var titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.styledText = §Localized.smsCodePlaceholder
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
        $0.buttonTitle = §Localized.PlaceholderView.buttonTitle
        $0.text = §Localized.PlaceholderView.text
        $0.delegate = output
        return $0
    }(ActionTitleTextDialog())
    
    // MARK: - Constraints
    
    private lazy var descriptionLabelTopConstraint = descriptionLabel.topAnchor.constraint(
        equalTo: codeControl.bottomAnchor,
        constant: Space.quadruple
    )
    
    private lazy var resendButtonBottomConstraint = resendCodeButton.bottomAnchor.constraint(
        equalTo: bottomLayoutGuide.topAnchor,
        constant: -Space.double
    )
    
    private lazy var placeholderViewBottomConstraint = placeholderView.bottomAnchor.constraint(
        equalTo: bottomLayoutGuide.topAnchor
    )
    
    // MARK: - Managing the View
    
    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.grayBackground)
        setupView()
        setupConstraints()
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
        codeControl.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeKeyboardObservers()
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Setup
    
    private func setupView() {
        [
            titleLabel,
            codeControl,
            codeErrorLabel,
            descriptionLabel,
            resendCodeButton,
            placeholderView,
        ].forEach(view.addSubview)
    }
    
    private func setupConstraints() {
        let titleLabelTopConstraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            titleLabelTopConstraint = titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Space.single / 4
            )
            resendButtonBottomConstraint = resendCodeButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Space.double
            )
            placeholderViewBottomConstraint = placeholderView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        } else {
            titleLabelTopConstraint = titleLabel.topAnchor.constraint(
                equalTo: topLayoutGuide.bottomAnchor,
                constant: Space.single / 4
            )
            resendButtonBottomConstraint = resendCodeButton.bottomAnchor.constraint(
                equalTo: bottomLayoutGuide.topAnchor,
                constant: -Space.double
            )
            placeholderViewBottomConstraint = placeholderView.bottomAnchor.constraint(
                equalTo: bottomLayoutGuide.topAnchor
            )
        }
        
        let constraints = [
            titleLabelTopConstraint,
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Space.double
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Space.double
            ),
            
            codeControl.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 2 * Space.triple
            ),
            codeControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            codeErrorLabel.topAnchor.constraint(
                equalTo: codeControl.bottomAnchor,
                constant: Space.double
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
            
            placeholderView.topAnchor.constraint(equalTo: view.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placeholderViewBottomConstraint,
        ]
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
    
    func keyboardDidShow(with keyboardInfo: KeyboardNotificationInfo) {}
    func keyboardDidHide(with keyboardInfo: KeyboardNotificationInfo) {}
    func keyboardDidUpdateFrame(_ keyboardFrame: CGRect) {}
    
    private func updateBottomConstraint(
        _ keyboardInfo: KeyboardNotificationInfo
    ) {
        guard let keyboardOffset = keyboardYOffset(from: keyboardInfo.endKeyboardFrame) else {
            return
        }
        
        let duration = keyboardInfo.animationDuration ?? 0.3

        var options: UIView.AnimationOptions = []
        if let animationCurve = keyboardInfo.animationCurve {
            options = UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue))
        }

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: options,
            animations: { [weak self] in
                guard let self = self else { return }
                self.resendButtonBottomConstraint.constant = -keyboardOffset - Space.double
                self.placeholderViewBottomConstraint.constant = -keyboardOffset - Space.double
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
        _ = codeControl.becomeFirstResponder()
    }

    func clearCode() {
        codeControl.clear()
    }

    func setCodeError(_ error: String?) {
        codeErrorLabel.styledText = error
        descriptionLabelTopConstraint.constant = error == nil
            ? Space.quadruple
            : Space.triple * 2
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
        showFullViewActivity(style: ActivityIndicatorView.Styles.cloudy)
    }

    func hideActivity() {
        hideFullViewActivity()
        codeControl.setIsEditable(true)
    }
}

// MARK: - ActivityIndicatorFullViewPresenting

extension PaymentAuthorizationViewController: ActivityIndicatorFullViewPresenting {}

// MARK: - Localized

private extension PaymentAuthorizationViewController {
    enum Localized: String {
        case smsCodePlaceholder = "Contract.placeholder.smsCode"
        
        enum PlaceholderView: String {
            case buttonTitle = "Common.PlaceholderView.buttonTitle"
            case text = "Common.PlaceholderView.text"
        }
    }
}
