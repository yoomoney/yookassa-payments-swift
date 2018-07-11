import UIKit

enum AuthCodeType {
    case sms
    case totp
}

protocol AuthCodeInputViewOutput: class {
    func didPressResendSmsButton(in view: AuthCodeInputViewInput)
    func authCodeInputView(_ view: AuthCodeInputViewInput, didChangeCode code: String)
}

protocol AuthCodeInputViewInput: class {
    func setSmsTimer(to timeInterval: TimeInterval)
    func setInvalidAnswerTextControlState()
    func setRequiredCodeLength(_ codeLength: Int)
}

private struct AuthCodeInputPresenterStyle: InputPresenterStyle {

    private let requiredCodeLength: Int

    init(requiredCodeLength: Int) {
        self.requiredCodeLength = requiredCodeLength
    }

    func removedFormatting(from string: String) -> String {
        return string
    }

    func appendedFormatting(to string: String) -> String {
        return string
    }

    var maximalLength: Int {
        return requiredCodeLength
    }
}

final class AuthCodeInputViewController: UIViewController {

    // MARK: - Settings properties

    private let authCodeType: AuthCodeType

    weak var output: AuthCodeInputViewOutput?

    // MARK: - SMS resend

    private var smsResendTimer: Timer?
    private var secondsTimer: Timer?

    private var seconds = 0

    private func updateSmsResendButton() {
        let title: String
        if seconds != 0 {
            title = String.localizedStringWithFormat(§Localized.resendSmsAfter, seconds)
        } else {
            title = §Localized.resendSms
        }

        resendSmsActionTemplate.isEnabled = seconds == 0
        resendSmsLabel.text = title
    }

    private func invalidateTimers() {
        smsResendTimer?.invalidate()
        secondsTimer?.invalidate()
    }

    // MARK: - Initializers

    @available(*, unavailable, message: "Use init(authCodeType:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(authCodeType:) instead")
    }

    @available(*, unavailable, message: "Use init(authCodeType:) instead")
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(authCodeType:) instead")
    }

    init(authCodeType type: AuthCodeType) {
        self.authCodeType = type
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Formatter

    fileprivate var inputPresenter: InputPresenter?

    fileprivate var requiredCodeLength: Int? {
        didSet {
            guard let requiredCodeLength = requiredCodeLength else { return }
            let textInputStyle = AuthCodeInputPresenterStyle(requiredCodeLength: requiredCodeLength)
            let inputPresenter = InputPresenter(textInputStyle: textInputStyle)
            inputPresenter.output = textControl
            self.inputPresenter = inputPresenter
        }
    }

    // MARK: - UI properties

    fileprivate lazy var textControl: TextControl = {
        $0.setStyles(TextControl.Styles.cardDataInput)
        switch authCodeType {
        case .sms:
            $0.topHint = §Localized.smsCodeTopHint
            $0.placeholder = §Localized.smsCodePlaceholder
        case .totp:
            $0.topHint = §Localized.totpTopHint
            $0.placeholder = §Localized.totpPlaceholder
        }
        $0.set(bottomHintText: §Localized.invalidAnswer, for: .error)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        return $0
    }(TextControl())

    fileprivate lazy var resendSmsActionTemplate: ActionTemplate = {
        $0.contentView = self.resendSmsLabel
        $0.setStyle(UILabel.ColorStyle.Link.normal, for: .normal)
        $0.setStyle(UILabel.ColorStyle.Link.highlighted, for: .highlighted)
        $0.setStyle(UILabel.ColorStyle.Link.disabled, for: .disabled)
        $0.addTarget(self, action: #selector(resendSmsDidPress), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(ActionTemplate())

    fileprivate lazy var resendSmsLabel: UILabel = {
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    // MARK: - Managing the View

    override func viewDidLoad() {
        super.viewDidLoad()
        updateSmsResendButton()
    }

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.grayBackground)
        loadSubviews()
        loadConstraints()
    }

    private func loadSubviews() {
        view.addSubview(textControl)

        if case .sms = authCodeType {
            view.addSubview(resendSmsActionTemplate)
        }
    }

    private func loadConstraints() {
        var format = "V:|-[textControl]"

        var views: [String: UIView] = [
            "textControl": textControl,
        ]

        if case .sms = authCodeType {
            format += "-(single)-[resendSmsButton]"
            views["resendSmsButton"] = resendSmsActionTemplate
        }

        format += "-|"

        var constraints = NSLayoutConstraint.constraints(withVisualFormat: format,
                                                         options: [],
                                                         metrics: Space.metrics,
                                                         views: views)

        constraints += [
            textControl.leading.constraint(equalTo: view.leading),
            textControl.trailing.constraint(equalTo: view.trailing),
        ]

        if case .sms = authCodeType {
            constraints += [
                resendSmsActionTemplate.leading.constraint(equalTo: view.leading),
                resendSmsActionTemplate.trailing.constraint(lessThanOrEqualTo: view.trailing),
                resendSmsLabel.leading.constraint(equalTo: resendSmsActionTemplate.leading),
                resendSmsLabel.trailing.constraint(equalTo: resendSmsActionTemplate.trailing),
                resendSmsLabel.top.constraint(equalTo: resendSmsActionTemplate.top),
                resendSmsLabel.bottom.constraint(equalTo: resendSmsActionTemplate.bottom),
            ]
        }

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions

    @objc
    private func resendSmsDidPress() {
        output?.didPressResendSmsButton(in: self)
    }

    @objc
    private func setResendSmsEnabled() {
        invalidateTimers()
        seconds = 0
        updateSmsResendButton()
    }

    @objc
    private func decreaseSecondsCounter() {
        seconds -= 1
        updateSmsResendButton()
    }
}

// MARK: - TextControlDelegate

extension AuthCodeInputViewController: TextControlDelegate {
    func textControlDidBeginEditing(_ textControl: TextControl) {}

    func textControlDidEndEditing(_ textControl: TextControl) {}

    func textControl(_ textControl: TextControl,
                     shouldChangeTextIn range: NSRange,
                     replacementText text: String) -> Bool {
        guard let inputPresenter = inputPresenter else {
            return true
        }
        inputPresenter.input(changeCharactersIn: range,
                             replacementString: text,
                             currentString: textControl.text ?? "")

        output?.authCodeInputView(self, didChangeCode: textControl.text ?? "")

        return false
    }

    func textControlDidChange(_ textControl: TextControl) {}
}

// MARK: - AuthCodeInputViewInput

extension AuthCodeInputViewController: AuthCodeInputViewInput {
    func setSmsTimer(to timeInterval: TimeInterval) {
        guard case .sms = authCodeType else {
            return
        }

        seconds = Int(timeInterval)
        updateSmsResendButton()

        activateTimers(timeInterval: timeInterval)
    }

    func setInvalidAnswerTextControlState() {
        textControl.state = .error
    }

    func setRequiredCodeLength(_ codeLength: Int) {
        requiredCodeLength = codeLength
    }

    private func activateTimers(timeInterval: TimeInterval) {

        smsResendTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                              target: self,
                                              selector: #selector(setResendSmsEnabled),
                                              userInfo: nil,
                                              repeats: false)
        secondsTimer = Timer.scheduledTimer(timeInterval: 1,
                             target: self,
                             selector: #selector(decreaseSecondsCounter),
                             userInfo: nil,
                             repeats: true)
    }
}

// MARK: - Localized
extension AuthCodeInputViewController {
    enum Localized: String {
        case resendSms = "Contract.resendSms"
        case resendSmsAfter = "Contract.format.resendSmsAfter"
        case smsCodePlaceholder = "Contract.placeholder.smsCode"
        case totpPlaceholder = "Contract.placeholder.totp"
        case smsCodeTopHint = "Contract.topHint.smsCode"
        case totpTopHint = "Contract.topHint.totp"

        case invalidAnswer = "Contract.bottomHint.invalidAnswer"
    }
}
