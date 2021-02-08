struct YooMoneyViewModel {
    let shopName: String
    let description: String?
    let price: PriceViewModel
    let fee: PriceViewModel?
    let paymentMethod: PaymentMethodViewModel
    let terms: TermsOfService
}

protocol YooMoneyViewInput: ActivityIndicatorFullViewPresenting, PlaceholderPresenting, NotificationPresenting {
    func setupViewModel(
        _ viewModel: YooMoneyViewModel
    )
    func setupAvatar(
        _ avatar: UIImage
    )
    func setSavePaymentMethodViewModel(
        _ savePaymentMethodViewModel: SavePaymentMethodViewModel
    )
    func setSaveAuthInAppSwitchItemView()
    func showPlaceholder(with message: String)
}

protocol YooMoneyViewOutput: ActionTitleTextDialogDelegate {
    func setupView()
    func didTapActionButton()
    func didTapLogout()
    func didTapTermsOfService(_ url: URL)
    func didTapOnSavePaymentMethod()
    func didChangeSavePaymentMethodState(
        _ state: Bool
    )
    func didChangeSaveAuthInAppState(
        _ state: Bool
    )
}
