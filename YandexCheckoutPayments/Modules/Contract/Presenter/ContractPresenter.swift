import FunctionalSwift

final class ContractPresenter {

    // MARK: - VIPER module properties

    var interactor: ContractInteractorInput!

    weak var view: ContractViewInput?
    weak var moduleOutput: ContractModuleOutput?
    weak var contractView: ContractTemplateViewInput?
    weak var paymentMethodView: PaymentMethodViewInput?

    // MARK: - Data

    fileprivate let inputData: ContractModuleInputData

    init(inputData: ContractModuleInputData) {
        self.inputData = inputData
    }
}

// MARK: - ContractViewOutput

extension ContractPresenter: ContractViewOutput {
    func setupView() {
        guard let contractView = contractView,
              let paymentMethodView = paymentMethodView else { return }
        contractView.setShopName(inputData.shopName)
        contractView.setPurchaseDescription(inputData.purchaseDescription)
        contractView.setPrice(inputData.price)
        contractView.setFee(inputData.fee)
        contractView.setTermsOfService(
            text: inputData.termsOfService.text,
            hyperlink: inputData.termsOfService.hyperlink,
            url: inputData.termsOfService.url
        )
        paymentMethodView.setPaymentMethodViewModel(inputData.paymentMethod)

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

// MARK: - PlaceholderViewDelegate

extension ContractPresenter: ActionTextDialogDelegate {
    func didPressButton() {
        moduleOutput?.didPressSubmitButton(on: self)
    }
}

// MARK: - ContractModuleInput

extension ContractPresenter: ContractModuleInput {
    func failLoginInYandexMoney(_ error: Error) {}
    func failResendSmsCode(_ error: Error) {}

    func failTokenizeData(_ error: Error) {
        let message = makeMessage(error)
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            let state: ContractPlaceholderState = .message(message)
            view.showPlaceholder(state: state)

            DispatchQueue.global().async { [weak self] in
                guard let strongSelf = self, let interactor = strongSelf.interactor else { return }
                let (authType, _) = interactor.makeTypeAnalyticsParameters()
                interactor.trackEvent(.screenError(authType: authType, scheme: strongSelf.inputData.tokenizeScheme))
            }
        }
    }
}

// MARK: - ContractInteractorOutput
extension ContractPresenter: ContractInteractorOutput {}

// MARK: - ContractTemplateDelegate

extension ContractPresenter: ContractTemplateViewOutput {
    func didPressSubmitButton(in contractTemplate: ContractTemplateViewInput) {
        moduleOutput?.didPressSubmitButton(on: self)
    }

    func didTapContract(_ contractTemplate: ContractTemplateViewInput) { }

    func didTapTermsOfService(_ url: URL) {
        moduleOutput?.contractModule(self, didTapTermsOfService: url)
    }
}

// MARK: - LargeIconItemViewOutput

extension ContractPresenter: LargeIconItemViewOutput {
    func didPressActionButton(in view: LargeIconItemViewInput) {
        moduleOutput?.didPressLogoutButton(on: self)
    }
}

// MARK: - IconButtonItemViewOutput

extension ContractPresenter: IconButtonItemViewOutput {
    func didPressButton(in itemView: IconButtonItemViewInput) {
        moduleOutput?.didPressChangeAction(on: self)
    }
}

// MARK: - LargeIconButtonItemViewOutput
extension ContractPresenter: LargeIconButtonItemViewOutput {
    func didPressLeftButton(in itemView: LargeIconButtonItemViewInput) {
        moduleOutput?.didPressLogoutButton(on: self)
    }

    func didPressRightButton(in itemView: LargeIconButtonItemViewInput) {
        moduleOutput?.didPressChangeAction(on: self)
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
