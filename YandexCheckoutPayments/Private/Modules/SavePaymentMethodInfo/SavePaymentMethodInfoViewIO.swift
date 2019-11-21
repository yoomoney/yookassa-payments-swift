protocol SavePaymentMethodInfoViewInput: class {
    func setSavePaymentMethodInfoViewModel(_ viewModel: SavePaymentMethodInfoViewModel)
    func setCustomizationSettings(_ customizationSettings: CustomizationSettings)
}

protocol SavePaymentMethodInfoViewOutput: class {
    func setupView()
}
