final class SberbankPresenter {

    // MARK: - VIPER module properties

    var interactor: ContractInteractorInput!

    weak var view: ContractViewInput?
    weak var moduleOutput: SberbankModuleOutput?
    weak var contractView: ContractTemplateViewInput?
    weak var paymentMethodView: PaymentMethodViewInput?
    weak var phoneInputView: PhoneNumberInputModuleInput?

    // MARK: - Data

    fileprivate let inputData: SberbankModuleInputData
    fileprivate var placeholderState: ContractPlaceholderState?
    fileprivate var phoneNumber: String = ""

    // MARK: - Initializers

    init(inputData: SberbankModuleInputData) {
        self.inputData = inputData
    }
}

// MARK: - ContractViewInput

extension SberbankPresenter: ContractViewOutput {
    func setupView() {
        guard let contractView = contractView,
              let paymentMethodView = paymentMethodView,
              let phoneInputView = phoneInputView else { return }
        contractView.setShopName(inputData.shopName)
        contractView.setPurchaseDescription(inputData.purchaseDescription)
        contractView.setPrice(inputData.price)
        contractView.setSubmitButtonEnabled(false)
        paymentMethodView.setPaymentMethodViewModel(inputData.paymentMethod)
        phoneInputView.setPlaceholder(§Localized.inputPlaceholder)
        phoneInputView.setHint(§Localized.inputHint)
        phoneInputView.setValue("+7")

        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self,
                  let interactor = strongSelf.interactor else { return }
            let (authType, _) = interactor.makeTypeAnalyticsParameters()
            let event: AnalyticsEvent = .screenPaymentContract(authType: authType,
                                                               scheme: strongSelf.inputData.tokenizeScheme)
            interactor.trackEvent(event)
        }
    }
}

// MARK: - ActionTextDialogDelegate

extension SberbankPresenter: ActionTextDialogDelegate {
    func didPressButton() {
        moduleOutput?.sberbank(self, phoneNumber: phoneNumber)
    }
}

// MARK: - ContractTemplateDelegate

extension SberbankPresenter: ContractTemplateViewOutput {
    func didPressSubmitButton(in contractTemplate: ContractTemplateViewInput) {
        view?.endEditing(true)
        moduleOutput?.sberbank(self, phoneNumber: phoneNumber)
    }

    func didTapContract(_ contractTemplate: ContractTemplateViewInput) {
        view?.endEditing(true)
    }
}

// MARK: - SberbankModuleInput

extension SberbankPresenter: SberbankModuleInput {

    func failLoginInYandexMoney(_ error: Error) { }

    func failResendSmsCode(_ error: Error) { }

    func failTokenizeData(_ error: Error) {
        handleError(error)
    }

    private func handleError(_ error: Error) {

        hideActivity()

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            let message = makeMessage(error)
            view.showPlaceholder(state: .message(message))

            DispatchQueue.global().async { [weak self] in
                guard let strongSelf = self, let interactor = strongSelf.interactor else { return }
                let (authType, _) = interactor.makeTypeAnalyticsParameters()
                interactor.trackEvent(.screenError(authType: authType, scheme: strongSelf.inputData.tokenizeScheme))
            }
        }
    }
}

// MARK: - IconButtonItemViewOutput

extension SberbankPresenter: IconButtonItemViewOutput {
    func didPressButton(in itemView: IconButtonItemViewInput) {
        view?.endEditing(true)
        moduleOutput?.didPressChangeAction(on: self)
    }
}

// MARK: - LargeIconItemViewOutput

extension SberbankPresenter: LargeIconItemViewOutput {
    func didPressActionButton(in view: LargeIconItemViewInput) { }
}

// MARK: - LargeIconButtonItemViewOutput

extension SberbankPresenter: LargeIconButtonItemViewOutput {
    func didPressLeftButton(in itemView: LargeIconButtonItemViewInput) { }

    func didPressRightButton(in itemView: LargeIconButtonItemViewInput) {
        moduleOutput?.didPressChangeAction(on: self)
    }
}

// MARK: - PhoneNumberInputModuleOutput

extension SberbankPresenter: PhoneNumberInputModuleOutput {
    func didChangePhoneNumber(_ phoneNumber: String) {
        self.phoneNumber = phoneNumber
        if phoneNumber.isEmpty {
            contractView?.setSubmitButtonEnabled(false)
        } else {
            contractView?.setSubmitButtonEnabled(true)
        }
    }
}

// MARK: - Localized

extension SberbankPresenter {
    enum Localized: String {
        case inputPlaceholder = "Contract.placeholder.sberbank"
        case inputHint = "Contract.bottomHint.sberbank"
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
