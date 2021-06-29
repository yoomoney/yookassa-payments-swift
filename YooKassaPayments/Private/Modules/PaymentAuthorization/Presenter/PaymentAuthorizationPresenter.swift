final class PaymentAuthorizationPresenter {

    // MARK: - VIPER

    weak var view: PaymentAuthorizationViewInput?
    weak var moduleOutput: PaymentAuthorizationModuleOutput?

    var interactor: PaymentAuthorizationInteractorInput!

    // MARK: - Init data

    private let authContextId: String
    private let processId: String
    private let tokenizeScheme: AnalyticsEvent.TokenizeScheme
    private var authTypeState: AuthTypeState

    // MARK: - Init

    init(
        authContextId: String,
        processId: String,
        tokenizeScheme: AnalyticsEvent.TokenizeScheme,
        authTypeState: AuthTypeState
    ) {
        self.authContextId = authContextId
        self.processId = processId
        self.tokenizeScheme = tokenizeScheme
        self.authTypeState = authTypeState
    }

    // MARK: - Stored properties

    private var possibleResendTime = Date()
    private var timer: Timer?

    private lazy var remainingTimeFormatter: DateComponentsFormatter = {
        $0.unitsStyle = .positional
        $0.zeroFormattingBehavior = .pad
        $0.allowedUnits = [.minute, .second]
        return $0
    }(DateComponentsFormatter())

    private lazy var nextSessionTimeFormatter: DateFormatter = {
        $0.locale = Locale.current
        $0.dateFormat = Localized.nextSessionTimeFormatter
        return $0
    }(DateFormatter())
}

// MARK: - PaymentAuthorizationViewOutput

extension PaymentAuthorizationPresenter: PaymentAuthorizationViewOutput {
    func setupView() {
        guard let view = view else { return }
        setupDescription()
        view.setResendCodeButtonIsEnabled(false)
        restartTimer(authTypeState: authTypeState)
    }

    func didGetCode(_ code: String) {
        view?.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.interactor.checkUserAnswer(
                authContextId: self.authContextId,
                authType: self.authTypeState.specific.type,
                answer: code,
                processId: self.processId
            )
        }
    }

    func didPressResendCode() {
        view?.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.interactor.resendCode(
                authContextId: self.authContextId,
                authType: self.authTypeState.specific.type
            )
        }
    }

    private func setRemainingTimeText(
        _ remainingTime: String
    ) {
        let remainingTimeText = String(
            format: Localized.remainingTime,
            remainingTime
        )
        DispatchQueue.main.async { [weak self] in
            self?.view?.setRemainingTimeText(remainingTimeText)
        }
    }

    private func setResendCodeButtonIsEnabled(
        _ isEnabled: Bool
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.setResendCodeButtonIsEnabled(isEnabled)
        }
    }

    private func setResendCodeButtonTitle(
        _ title: String
    ) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.setResendCodeButtonTitle(title)
        }
    }

    private func restartTimer(authTypeState: AuthTypeState) {
        guard case .sms(let smsDescription?) = authTypeState.specific else {
            return
        }

        view?.setCodeLength(smsDescription.codeLength)

        if let nextSessionTimeLeft = smsDescription.nextSessionTimeLeft {
            possibleResendTime = Date().addingTimeInterval(TimeInterval(nextSessionTimeLeft))
        }

        timer?.invalidate()
        timer = nil

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let timer = Timer.scheduledTimer(
                withTimeInterval: Constants.timerInterval,
                repeats: true,
                block: self.handleTimerTick
            )
            self.timer = timer
            self.handleTimerStart()
        }
    }

    private func handleTimerTick(_ timer: Timer?) {
        let timeInterval = possibleResendTime.timeIntervalSince(Date())
        if timeInterval > 0 {
            guard let remainingTime = remainingTimeFormatter.string(from: timeInterval) else { return }
            setRemainingTimeText(remainingTime)
        } else {
            handleTimerStop()
        }
    }

    private func handleTimerStart() {
        setResendCodeButtonIsEnabled(false)
        handleTimerTick(timer)
    }

    private func handleTimerStop() {
        timer?.invalidate()
        timer = nil

        setResendCodeButtonTitle(Localized.resendSms)
        setResendCodeButtonIsEnabled(true)
    }

    private func setupDescription() {
        if let phoneTitle = interactor.getWalletPhoneTitle() {
            view?.setDescription(String(
                format: Localized.descriptionWithPhone,
                phoneTitle
            ))
        } else {
            view?.setDescription(Localized.descriptionWithoutPhone)
        }
    }
}

// MARK: - ActionTitleTextDialogDelegate

extension PaymentAuthorizationPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(
        in actionTitleTextDialog: ActionTitleTextDialog
    ) {
        view?.hidePlaceholder()
        didPressResendCode()
    }
}

// MARK: - PaymentAuthorizationInteractorOutput

extension PaymentAuthorizationPresenter: PaymentAuthorizationInteractorOutput {
    func didResendCode(
        authTypeState: AuthTypeState
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let view = self.view else { return }
            view.clearCode()
            view.setCodeError(nil)
            self.setupDescription()
            view.hideActivity()
            self.authTypeState = authTypeState
            self.restartTimer(authTypeState: authTypeState)
        }
    }

    func didFailResendCode(
        _ error: Error
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.hideActivity()

            switch error {
            case is WalletLoginProcessingError:
                self.handleError(error)
            default:
                let message = makeMessage(error)
                self.view?.showPlaceholder(title: message)
            }

            DispatchQueue.global().async { [weak self] in
                guard let self = self, let interactor = self.interactor else { return }
                let (authType, _) = interactor.makeTypeAnalyticsParameters()
                let event: AnalyticsEvent = .screenError(
                    authType: authType,
                    scheme: self.tokenizeScheme,
                    sdkVersion: Bundle.frameworkVersion
                )
                interactor.trackEvent(event)
            }
        }
    }

    func didCheckUserAnswer(
        _ response: WalletLoginResponse
    ) {
        moduleOutput?.didCheckUserAnswer(
            self,
            response: response
        )

        if case .authorized = response {
            DispatchQueue.global().async { [weak self] in
                guard let interactor = self?.interactor else { return }
                let event: AnalyticsEvent = .actionPaymentAuthorization(
                    authPaymentStatus: .success,
                    sdkVersion: Bundle.frameworkVersion
                )
                interactor.trackEvent(event)
            }
        }
    }

    func didFailCheckUserAnswer(
        _ error: Error
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.clearCode()
            self.view?.hideActivity()
            self.handleError(error)

            DispatchQueue.global().async { [weak self] in
                guard let interactor = self?.interactor else { return }
                let event: AnalyticsEvent = .actionPaymentAuthorization(
                    authPaymentStatus: .fail,
                    sdkVersion: Bundle.frameworkVersion
                )
                interactor.trackEvent(event)
            }
        }
    }

    private func handleError(
        _ error: Error
    ) {
        switch error {
        case WalletLoginProcessingError.invalidAnswer(let authTypeState):
            guard let activeSession = authTypeState?.activeSession else {
                view?.setCodeError(Localized.Error.invalidAnswer)
                return
            }

            view?.setCodeError(String(
                format: Localized.Error.invalidAnswerSessionsLeft,
                activeSession.attemptsLeft
            ))

        case WalletLoginProcessingError.verifyAttemptsExceeded(let authTypeState):
            guard case .sms(let smsDescription?) = authTypeState?.specific,
                  let nextSessionTimeLeft = smsDescription.nextSessionTimeLeft else {
                presentError(message: Localized.Error.verifyAttemptsExceeded)
                return
            }

            let nextSessionDate = Date().addingTimeInterval(TimeInterval(nextSessionTimeLeft))

            let nextSessionTimeText = String(
                format: Localized.Error.verifyAttemptsExceededNextSession,
                nextSessionTimeFormatter.string(from: nextSessionDate)
            )
            presentError(message: nextSessionTimeText)

        case WalletLoginProcessingError.sessionDoesNotExist:
            showPlaceholder(error: error)

        default:
            let message = makeMessage(error)
            presentError(message: message)
        }
    }

    private func showPlaceholder(error: Error) {
        let message = makeMessage(error)
        view?.showPlaceholder(title: message)
    }

    private func presentError(message: String) {
        view?.setDescriptionError(message)
        view?.setCodeError(nil)
    }
}

// MARK: - PaymentAuthorizationModuleInput

extension PaymentAuthorizationPresenter: PaymentAuthorizationModuleInput {}

// MARK: - Constants

private extension PaymentAuthorizationPresenter {
    enum Constants {
        static let timerInterval: TimeInterval = 1
    }
}

// MARK: - Constants

private extension PaymentAuthorizationPresenter {
    enum Localized {
        static let nextSessionTimeFormatter = NSLocalizedString(
            "PaymentAuthorization.nextSessionTimeFormatter",
            bundle: Bundle.framework,
            value: "d MMMM в HH:mm",
            comment: ""
        )
        static let descriptionWithPhone = NSLocalizedString(
            "PaymentAuthorization.description.witPhone",
            bundle: Bundle.framework,
            value: "Отправили проверочный код на %@",
            comment: ""
        )
        static let descriptionWithoutPhone = NSLocalizedString(
            "PaymentAuthorization.description.withoutPhone",
            bundle: Bundle.framework,
            value: "Отправили проверочный код",
            comment: ""
        )
        static let remainingTime = NSLocalizedString(
            "PaymentAuthorization.remainingTime",
            bundle: Bundle.framework,
            value: "Получить новый код через %@",
            comment: ""
        )
        static let resendSms = NSLocalizedString(
            "Contract.resendSms",
            bundle: Bundle.framework,
            value: "Отправить снова",
            comment: ""
        )

        enum Error {
            static let invalidAnswer = NSLocalizedString(
                "PaymentAuthorization.invalidAnswer",
                bundle: Bundle.framework,
                value: "Это не тот код. Проверьте и введите ещё раз",
                comment: ""
            )
            static let invalidAnswerSessionsLeft = NSLocalizedString(
                "PaymentAuthorization.invalidAnswer.sessionsLeft",
                bundle: Bundle.framework,
                value: "Это не тот код. Осталось попыток: %d",
                comment: ""
            )
            static let verifyAttemptsExceeded = NSLocalizedString(
                "PaymentAuthorization.verifyAttemptsExceeded",
                bundle: Bundle.framework,
                value: "Попытки закончились",
                comment: ""
            )
            static let verifyAttemptsExceededNextSession = NSLocalizedString(
                "PaymentAuthorization.verifyAttemptsExceeded.nextSession",
                bundle: Bundle.framework,
                value: "Попытки закончились. Попробовать можно %@",
                comment: ""
            )
        }
    }
}

// MARK: - Make message from Error

private func makeMessage(_ error: Error) -> String {
    let message: String

    switch error {
    case let error as PresentableError:
        message = error.message
    default:
        message = CommonLocalized.Error.unknown
    }

    return message
}
