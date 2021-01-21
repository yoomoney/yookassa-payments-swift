final class SavePaymentMethodInfoPresenter {

    // MARK: - VIPER

    weak var view: SavePaymentMethodInfoViewInput?

    // MARK: - Init data

    private let inputData: SavePaymentMethodInfoModuleInputData

    // MARK: - Init

    init(
        inputData: SavePaymentMethodInfoModuleInputData
    ) {
        self.inputData = inputData
    }
}

// MARK: - SavePaymentMethodInfoViewOutput

extension SavePaymentMethodInfoPresenter: SavePaymentMethodInfoViewOutput {
    func setupView() {
        guard let view = view else { return }
        let viewModel = SavePaymentMethodInfoViewModel(
            headerText: inputData.headerValue,
            bodyText: inputData.bodyValue
        )
        view.setSavePaymentMethodInfoViewModel(viewModel)
        view.setCustomizationSettings(inputData.customizationSettings)
    }
}
