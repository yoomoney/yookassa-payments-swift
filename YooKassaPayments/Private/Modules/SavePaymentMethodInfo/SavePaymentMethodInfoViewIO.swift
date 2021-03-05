protocol SavePaymentMethodInfoViewInput: class {
    func setSavePaymentMethodInfoViewModel(_ viewModel: SavePaymentMethodInfoViewModel)
}

protocol SavePaymentMethodInfoViewOutput: class {
    func setupView()
}
