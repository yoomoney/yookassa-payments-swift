protocol RecurringInfoViewInput: class {
    func setRecurringInfoViewModel(_ viewModel: RecurringInfoViewModel)
    func setCustomizationSettings(_ customizationSettings: CustomizationSettings)
}

protocol RecurringInfoViewOutput: class {
    func setupView()
}
