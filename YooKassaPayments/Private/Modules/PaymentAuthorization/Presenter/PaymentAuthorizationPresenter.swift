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
        $0.dateFormat = §Localized.nextSessionTimeFormatter
        return $0
    }(DateFormatter())
}

// MARK: - PaymentAuthorizationViewOutput

extension PaymentAuthorizationPresenter: PaymentAuthorizationViewOutput {
    func setupView() {
        if let phoneTitle = interactor.getWalletPhoneTitle() {
            view?.setDescription(String(
                format: §Localized.descriptionWithPhone,
                phoneTitle
            ))
        } else {
            view?.setDescription(§Localized.descriptionWithoutPhone)
        }
        
        view?.setResendCodeButtonIsEnabled(false)
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
            format: §Localized.remainingTime,
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

        if let sessionTimeLeft = smsDescription.sessionTimeLeft {
            possibleResendTime = Date().addingTimeInterval(TimeInterval(sessionTimeLeft))
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

        setResendCodeButtonTitle(§Localized.resendSms)
        setResendCodeButtonIsEnabled(true)
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

extension PaymentAuthorizationPresenter: PaymentAuthorizationInteractorOutput {
    func didResendCode(
        authTypeState: AuthTypeState
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.clearCode()
            self.view?.hideActivity()
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
        case WalletLoginProcessingError.invalidAnswer:
            guard case .sms(let smsDescription?) = authTypeState.specific else {
                view?.setCodeError(§Localized.Error.invalidAnswer)
                return
            }
            
            
            view?.setCodeError(String(
                format: §Localized.Error.invalidAnswerSessionsLeft,
                smsDescription.sessionsLeft
            ))
            
        case WalletLoginProcessingError.verifyAttemptsExceeded:
            guard case .sms(let smsDescription?) = authTypeState.specific,
                  let nextSessionTimeLeft = smsDescription.nextSessionTimeLeft else {
                presentError(message: §Localized.Error.verifyAttemptsExceeded)
                return
            }
            
            let nextSessionDate = Date().addingTimeInterval(TimeInterval(nextSessionTimeLeft))
            
            let nextSessionTimeText = String(
                format: §Localized.Error.verifyAttemptsExceededNextSession,
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
        view?.endEditing()
        view?.setDescriptionError(message)
        view?.setCodeError(nil)
        view?.setResendCodeButtonHidden(true)
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
    enum Localized: String {
        case nextSessionTimeFormatter = "PaymentAuthorization.nextSessionTimeFormatter"
        
        case descriptionWithPhone = "PaymentAuthorization.description.witPhone"
        case descriptionWithoutPhone = "PaymentAuthorization.description.withoutPhone"
        
        case remainingTime = "PaymentAuthorization.remainingTime"
        
        case resendSms = "Contract.resendSms"
        
        enum Error: String {
            case invalidAnswer = "PaymentAuthorization.invalidAnswer"
            case invalidAnswerSessionsLeft = "PaymentAuthorization.invalidAnswer.sessionsLeft"
            
            case verifyAttemptsExceeded = "PaymentAuthorization.verifyAttemptsExceeded"
            case verifyAttemptsExceededNextSession = "PaymentAuthorization.verifyAttemptsExceeded.nextSession"
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
        message = §CommonLocalized.Error.unknown
    }

    return message
}
