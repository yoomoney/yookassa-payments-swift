final class RecurringInfoPresenter {

    // MARK: - VIPER properties

    weak var view: RecurringInfoViewInput?

    // MARK: - Init

    private let inputData: RecurringInfoModuleInputData

    init(inputData: RecurringInfoModuleInputData) {
        self.inputData = inputData
    }
}

// MARK: - RecurringInfoViewOutput

extension RecurringInfoPresenter: RecurringInfoViewOutput {
    func setupView() {
        guard let view = view else { return }
        let viewModel = RecurringInfoViewModel(
            headerText: inputData.headerValue,
            bodyText: inputData.bodyValue
        )
        view.setRecurringInfoViewModel(viewModel)
        view.setCustomizationSettings(inputData.customizationSettings)
    }
}
