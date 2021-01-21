import UIKit

final class WalletAuthParametersPresenter {

    // MARK: - VIPER

    var interactor: ContractInteractorInput!

    weak var view: ContractViewInput?
    weak var moduleOutput: WalletAuthParametersModuleOutput?
    weak var contractView: ContractTemplateViewInput?
    weak var paymentMethodView: PaymentMethodViewInput?
    weak var isReusableTokenView: SwitchItemViewInput?

    // MARK: - Init data

    fileprivate let inputData: WalletAuthParametersModuleInputData

    // MARK: - Init

    init(inputData: WalletAuthParametersModuleInputData) {
        self.inputData = inputData
    }

    // MARK: - Properties

    fileprivate var isReusableToken = true
}

// MARK: - ContractViewOutput

extension WalletAuthParametersPresenter: ContractViewOutput {
    func setupView() {
        guard let contractView = contractView,
              let paymentMethodView = paymentMethodView,
              let saveAuthInAppView = isReusableTokenView else { return }
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
        saveAuthInAppView.title = §Localized.saveAuthInApp
        saveAuthInAppView.state = isReusableToken

        if let savePaymentMethodViewModel = inputData.savePaymentMethodViewModel {
            contractView.setSavePaymentMethodViewModel(savePaymentMethodViewModel)
        }

        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self,
                  let interactor = strongSelf.interactor else { return }
            let (authType, _) = interactor.makeTypeAnalyticsParameters()
            let event: AnalyticsEvent = .screenPaymentContract(
                authType: authType,
                scheme: strongSelf.inputData.tokenizeScheme
            )
            interactor.trackEvent(event)
        }
    }
}

// MARK: - PlaceholderViewDelegate

extension WalletAuthParametersPresenter: ActionTextDialogDelegate {
    // This is button in placeholder view. Need fix in UI library
    func didPressButton() {
        moduleOutput?.walletAuthParameters(self, loginWithReusableToken: isReusableToken)
    }
}

// MARK: - ContractTemplateDelegate

extension WalletAuthParametersPresenter: ContractTemplateViewOutput {
    func didPressSubmitButton(in contractTemplate: ContractTemplateViewInput) {
        moduleOutput?.walletAuthParameters(self, loginWithReusableToken: isReusableToken)
    }

    func didTapContract(_ contractTemplate: ContractTemplateViewInput) { }

    func didTapTermsOfService(_ url: URL) {
        moduleOutput?.walletAuthParameters(self, didTapTermsOfService: url)
    }

    func linkedSwitchItemView(
        _ itemView: LinkedSwitchItemViewInput,
        didChangeState state: Bool
    ) {
        moduleOutput?.walletAuthParameters(
            self,
            didChangeSavePaymentMethodState: state
        )
    }

    func didTapOnSavePaymentMethod() {
        moduleOutput?.didTapOnSavePaymentMethodInfo(on: self)
    }
}

// MARK: - SwitchItemViewDelegate

extension WalletAuthParametersPresenter: SwitchItemViewOutput {
    func switchItemView(
        _ itemView: SwitchItemViewInput,
        didChangeState state: Bool
    ) {
        isReusableToken = state
    }
}

// MARK: - LargeIconItemViewOutput

extension WalletAuthParametersPresenter: LargeIconItemViewOutput {
    func didPressActionButton(in view: LargeIconItemViewInput) {
        moduleOutput?.didPressLogoutButton(on: self)
    }
}

// MARK: - WalletAuthParametersModuleInput

extension WalletAuthParametersPresenter: WalletAuthParametersModuleInput {
    func didFailLoginInWallet(_ error: Error) {
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

extension WalletAuthParametersPresenter: IconButtonItemViewOutput {
    func didPressButton(in itemView: IconButtonItemViewInput) {
        moduleOutput?.didPressChangeAction(on: self)
    }
}

// MARK: - LargeIconButtonItemViewOutput

extension WalletAuthParametersPresenter: LargeIconButtonItemViewOutput {
    func didPressLeftButton(in itemView: LargeIconButtonItemViewInput) {
        moduleOutput?.didPressLogoutButton(on: self)
    }

    func didPressRightButton(in itemView: LargeIconButtonItemViewInput) {
        moduleOutput?.didPressChangeAction(on: self)
    }
}

// MARK: - Localized

private extension WalletAuthParametersPresenter {
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
