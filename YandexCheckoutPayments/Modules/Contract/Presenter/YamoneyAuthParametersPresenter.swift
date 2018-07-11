import UIKit

final class YamoneyAuthParametersPresenter {

    // MARK: - VIPER module properties

    var interactor: ContractInteractorInput!

    weak var view: ContractViewInput?
    weak var moduleOutput: YamoneyAuthParametersModuleOutput?
    weak var contractView: ContractTemplateViewInput?
    weak var paymentMethodView: PaymentMethodViewInput?
    weak var isReusableTokenView: SwitchItemViewInput?

    // MARK: - Data

    fileprivate let inputData: YamoneyAuthParametersModuleInputData
    fileprivate var isReusableToken = true

    init(inputData: YamoneyAuthParametersModuleInputData) {
        self.inputData = inputData
    }
}

// MARK: - ContractViewOutput

extension YamoneyAuthParametersPresenter: ContractViewOutput {
    func setupView() {
        guard let contractView = contractView,
              let paymentMethodView = paymentMethodView,
              let saveAuthInAppView = isReusableTokenView else { return }
        contractView.setShopName(inputData.shopName)
        contractView.setPurchaseDescription(inputData.purchaseDescription)
        contractView.setPrice(inputData.price)
        paymentMethodView.setPaymentMethodViewModel(inputData.paymentMethod)
        saveAuthInAppView.title = String.localizedStringWithFormat(§Localized.saveAuthInApp, inputData.shopName)
        saveAuthInAppView.state = isReusableToken

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

extension YamoneyAuthParametersPresenter: ActionTextDialogDelegate {
    // This is button in placeholder view. Need fix in UI library
    func didPressButton() {
        moduleOutput?.yamoneyAuthParameters(self, loginWithReusableToken: isReusableToken)
    }
}

// MARK: - ContractTemplateDelegate

extension YamoneyAuthParametersPresenter: ContractTemplateViewOutput {
    func didPressSubmitButton(in contractTemplate: ContractTemplateViewInput) {
        moduleOutput?.yamoneyAuthParameters(self, loginWithReusableToken: isReusableToken)
    }

    func didTapContract(_ contractTemplate: ContractTemplateViewInput) { }
}

// MARK: - SwitchItemViewDelegate

extension YamoneyAuthParametersPresenter: SwitchItemViewOutput {
    func switchItemView(_ itemView: SwitchItemViewInput, didChangeState state: Bool) {
        isReusableToken = state
    }
}

// MARK: - LargeIconItemViewOutput

extension YamoneyAuthParametersPresenter: LargeIconItemViewOutput {
    func didPressActionButton(in view: LargeIconItemViewInput) {
        moduleOutput?.didPressLogoutButton(on: self)
    }
}

// MARK: - YamoneyAuthParametersModuleInput

extension YamoneyAuthParametersPresenter: YamoneyAuthParametersModuleInput {
    func failLoginInYandexMoney(_ error: Error) {
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

    func failTokenizeData(_ error: Error) {}
    func failResendSmsCode(_ error: Error) {}
}

// MARK: - IconButtonItemViewOutput

extension YamoneyAuthParametersPresenter: IconButtonItemViewOutput {
    func didPressButton(in itemView: IconButtonItemViewInput) {
        moduleOutput?.didPressChangeAction(on: self)
    }
}

// MARK: - LargeIconButtonItemViewOutput

extension YamoneyAuthParametersPresenter: LargeIconButtonItemViewOutput {
    func didPressLeftButton(in itemView: LargeIconButtonItemViewInput) {
        moduleOutput?.didPressLogoutButton(on: self)
    }

    func didPressRightButton(in itemView: LargeIconButtonItemViewInput) {
        moduleOutput?.didPressChangeAction(on: self)
    }
}

// MARK: - Localized

private extension YamoneyAuthParametersPresenter {
    enum Localized: String {
        case saveAuthInApp = "Contract.format.saveAuthInApp"
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
