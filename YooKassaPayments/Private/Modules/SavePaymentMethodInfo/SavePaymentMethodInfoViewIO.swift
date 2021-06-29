protocol SavePaymentMethodInfoViewInput: AnyObject {
    func setSavePaymentMethodInfoViewModel(_ viewModel: SavePaymentMethodInfoViewModel)
}

protocol SavePaymentMethodInfoViewOutput: AnyObject {
    func setupView()
}
