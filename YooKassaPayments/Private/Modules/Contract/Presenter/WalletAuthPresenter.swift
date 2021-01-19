import struct YooKassaWalletApi.AuthTypeState

final class WalletAuthPresenter {

    // MARK: - VIPER module properties

    var interactor: ContractInteractorInput!

    weak var view: ContractViewInput?
    weak var moduleOutput: WalletAuthModuleOutput?
    weak var contractView: ContractTemplateViewInput?
    weak var paymentMethodView: PaymentMethodViewInput?
    weak var authCodeInputView: AuthCodeInputViewInput?

    var authTypeState: AuthTypeState

    // MARK: - PlaceholderState

    fileprivate var placeholderState: ContractPlaceholderState?

    // MARK: - Data

    fileprivate let inputData: WalletAuthModuleInputData
    fileprivate var authCode: String = ""
    fileprivate var requiredCodeLength = 0

    init(inputData: WalletAuthModuleInputData) {
        self.inputData = inputData

        authTypeState = inputData.authTypeState
    }
}

// MARK: - ContractViewOutput

extension WalletAuthPresenter: ContractViewOutput {
    func setupView() {
        guard let contractView = contractView,
              let paymentMethodView = paymentMethodView else { return }
        contractView.setShopName(inputData.shopName)
        contractView.setPurchaseDescription(inputData.purchaseDescription)
        contractView.setPrice(inputData.price)
        contractView.setFee(inputData.fee)
        contractView.setSubmitButtonEnabled(false)
        contractView.setTermsOfService(
            text: inputData.termsOfService.text,
            hyperlink: inputData.termsOfService.hyperlink,
            url: inputData.termsOfService.url
        )
        paymentMethodView.setPaymentMethodViewModel(inputData.paymentMethod)

        setSmsTimer(authTypeState: inputData.authTypeState)
    }
}

// MARK: - PlaceholderViewDelegate

extension WalletAuthPresenter: ActionTextDialogDelegate {
    // This is button in placeholder view. Need fix in UI library
    func didPressButton() {
        guard let placeholderState = placeholderState else { return }
        switch placeholderState {
            case .message:
                moduleOutput?.walletAuth(self,
                                          authContextId: inputData.authContextId,
                                          authType: authTypeState.specific.type,
                                          answer: authCode,
                                          processId: inputData.processId)

        case .failResendSmsCode:
            moduleOutput?.walletAuth(self,
                                      resendSmsCodeWithContextId: inputData.authContextId,
                                      authType: inputData.authTypeState.specific.type)

        case .authCheckInvalidContext(_, let error):
            hidePlaceholder()
            showActivity()
            moduleOutput?.walletAuth(self, didFinishWithError: error)

        case .sessionBroken:
            moduleOutput?.walletAuth(self,
                                      resendSmsCodeWithContextId: inputData.authContextId,
                                      authType: inputData.authTypeState.specific.type)

        case .verifyAttemptsExceeded(_, let error):
            hidePlaceholder()
            showActivity()
            moduleOutput?.walletAuth(self, didFinishWithError: error)

        case .executeError(_, let error):
            hidePlaceholder()
            showActivity()
            moduleOutput?.walletAuth(self, didFinishWithError: error)
        }
    }
}

// MARK: - ContractModuleInput

extension WalletAuthPresenter: WalletAuthModuleInput {
    func setAuthTypeState(_ authTypeState: AuthTypeState) {
        hideActivity()
        self.authTypeState = authTypeState

        DispatchQueue.main.async { [weak self] in
            self?.setSmsTimer(authTypeState: authTypeState)
        }
    }

    func didFailLoginInWallet(_ error: Error) {
        handleError(error)
    }

    func failTokenizeData(_ error: Error) {
        handleError(error)
    }

    func failResendSmsCode(_ error: Error) {
        switch error {
        case is WalletLoginProcessingError:
            handleError(error)
        default:
            hideActivity()
            showPlaceholder(state: .failResendSmsCode)
        }
    }
}

// MARK: - ContractTemplateDelegate

extension WalletAuthPresenter: ContractTemplateViewOutput {
    func didPressSubmitButton(in contractTemplate: ContractTemplateViewInput) {
        view?.endEditing(true)
        moduleOutput?.walletAuth(self,
                                  authContextId: inputData.authContextId,
                                  authType: authTypeState.specific.type,
                                  answer: authCode,
                                  processId: inputData.processId)
    }

    func didTapContract(_ contractTemplate: ContractTemplateViewInput) {
        view?.endEditing(true)
    }

    func didTapTermsOfService(_ url: URL) {
        moduleOutput?.walletAuth(self, didTapTermsOfService: url)
    }

    func linkedSwitchItemView(_ itemView: LinkedSwitchItemViewInput, didChangeState state: Bool) { }

    func didTapOnSavePaymentMethod() { }
}

extension WalletAuthPresenter: AuthCodeInputViewOutput {
    func didPressResendSmsButton(in view: AuthCodeInputViewInput) {

        showActivity()
        self.view?.endEditing(true)

        moduleOutput?.walletAuth(self,
                                  resendSmsCodeWithContextId: inputData.authContextId,
                                  authType: inputData.authTypeState.specific.type)
    }

    func authCodeInputView(_ view: AuthCodeInputViewInput, didChangeCode code: String) {
        contractView?.setSubmitButtonEnabled(code.count >= requiredCodeLength)
        authCode = code
    }
}

// MARK: - LargeIconItemViewOutput

extension WalletAuthPresenter: LargeIconItemViewOutput {
    func didPressActionButton(in view: LargeIconItemViewInput) {
        moduleOutput?.didPressLogoutButton(on: self)
    }
}

// MARK: - IconButtonItemViewOutput

extension WalletAuthPresenter: IconButtonItemViewOutput {
    func didPressButton(in itemView: IconButtonItemViewInput) {
        moduleOutput?.didPressChangeAction(on: self)
    }
}

// MARK: - LargeIconButtonItemViewOutput

extension WalletAuthPresenter: LargeIconButtonItemViewOutput {
    func didPressLeftButton(in itemView: LargeIconButtonItemViewInput) {
        moduleOutput?.didPressLogoutButton(on: self)
    }

    func didPressRightButton(in itemView: LargeIconButtonItemViewInput) {
        moduleOutput?.didPressChangeAction(on: self)
    }
}

// MARK: - Errors handling

private extension WalletAuthPresenter {
    func handleError(_ error: Error) {

        hideActivity()

        switch error {
        case WalletLoginProcessingError.invalidAnswer:
            handleInvalidAnswer()

        case WalletLoginProcessingError.authCheckInvalidContext:
            let message = makeMessage(error)
            showPlaceholder(state: .authCheckInvalidContext(message: message, error: error))

        case WalletLoginProcessingError.sessionDoesNotExist:
            let message = makeMessage(error)
            showPlaceholder(state: .sessionBroken(message: message, error: error))

        case WalletLoginProcessingError.verifyAttemptsExceeded:
            let message = makeMessage(error)
            showPlaceholder(state: .verifyAttemptsExceeded(message: message, error: error))

        case WalletLoginProcessingError.executeError:
            let message = makeMessage(error)
            showPlaceholder(state: .executeError(message: message, error: error))

        default:
            presentError(error)
        }
    }

    func showPlaceholder(state: ContractPlaceholderState) {
        placeholderState = state

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.showPlaceholder(state: state)

            DispatchQueue.global().async { [weak self] in
                guard let strongSelf = self, let interactor = strongSelf.interactor else { return }
                let (authType, _) = interactor.makeTypeAnalyticsParameters()
                interactor.trackEvent(.screenError(authType: authType, scheme: strongSelf.inputData.tokenizeScheme))
            }
        }
    }

    private func presentError(_ error: Error) {
        let message = makeMessage(error)
        showPlaceholder(state: .message(message))
    }

    private func handleInvalidAnswer() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self,
                  let authCodeInputView = strongSelf.authCodeInputView else {
                return
            }
            authCodeInputView.setInvalidAnswerTextControlState()
        }
    }
}

// MARK: - Update view by models {

private extension WalletAuthPresenter {
    func setSmsTimer(authTypeState: AuthTypeState) {
        guard let authCodeInputView = authCodeInputView else { return }

        if case .sms(let smsDescription?) = authTypeState.specific {

            requiredCodeLength = smsDescription.codeLength
            authCodeInputView.setRequiredCodeLength(requiredCodeLength)

            if let nextSessionTimeLeft = smsDescription.nextSessionTimeLeft {
                authCodeInputView.setSmsTimer(to: TimeInterval(nextSessionTimeLeft))
            }

        } else if case .totp(let totpDescription?) = authTypeState.specific {

            requiredCodeLength = totpDescription.codeLength
            authCodeInputView.setRequiredCodeLength(requiredCodeLength)
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
