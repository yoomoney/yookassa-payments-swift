final class ApplePayContractPresenter {

    // MARK: - VIPER

    var interactor: ContractInteractorInput!

    weak var view: ContractViewInput?
    weak var moduleOutput: ApplePayContractModuleOutput?
    weak var contractView: ContractTemplateViewInput?
    weak var paymentMethodView: PaymentMethodViewInput?

    // MARK: - Init data

    private let inputData: ApplePayContractModuleInputData

    // MARK: - Init

    init(inputData: ApplePayContractModuleInputData) {
        self.inputData = inputData
    }
}

// MARK: - ContractViewOutput

extension ApplePayContractPresenter: ContractViewOutput {
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

        if let savePaymentMethodViewModel = inputData.savePaymentMethodViewModel {
            contractView.setSavePaymentMethodViewModel(savePaymentMethodViewModel)
        }
    }
}

// MARK: - PlaceholderViewDelegate

extension ApplePayContractPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(
        in actionTitleTextDialog: ActionTitleTextDialog
    ) {
        moduleOutput?.didPressSubmitButton(on: self)
    }
}

// MARK: - ApplePayContractModuleInput

extension ApplePayContractPresenter: ApplePayContractModuleInput {}

// MARK: - ContractInteractorOutput

extension ApplePayContractPresenter: ContractInteractorOutput {}

// MARK: - ContractTemplateDelegate

extension ApplePayContractPresenter: ContractTemplateViewOutput {
    func didPressSubmitButton(in contractTemplate: ContractTemplateViewInput) {
        moduleOutput?.didPressSubmitButton(on: self)
    }

    func didTapContract(_ contractTemplate: ContractTemplateViewInput) { }

    func didTapTermsOfService(_ url: URL) {
        moduleOutput?.applePayContractModule(self, didTapTermsOfService: url)
    }

    func linkedSwitchItemView(
        _ itemView: LinkedSwitchItemViewInput,
        didChangeState state: Bool
    ) {
        moduleOutput?.applePayContractModule(
            self,
            didChangeSavePaymentMethodState: state
        )
    }

    func didTapOnSavePaymentMethod() {
        moduleOutput?.didTapOnSavePaymentMethodInfo(on: self)
    }
}

// MARK: - LargeIconItemViewOutput

extension ApplePayContractPresenter: LargeIconItemViewOutput {
    func didPressActionButton(in view: LargeIconItemViewInput) {}
}

// MARK: - IconButtonItemViewOutput

extension ApplePayContractPresenter: IconButtonItemViewOutput {
    func didPressButton(in itemView: IconButtonItemViewInput) {
        moduleOutput?.didPressChangeAction(on: self)
    }
}

// MARK: - LargeIconButtonItemViewOutput

extension ApplePayContractPresenter: LargeIconButtonItemViewOutput {
    func didPressRightButton(in itemView: LargeIconButtonItemViewInput) {
        moduleOutput?.didPressChangeAction(on: self)
    }
}
