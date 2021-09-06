protocol BankCardRepeatViewInput: ActivityIndicatorPresenting, PlaceholderPresenting, NotificationPresenting {
    func endEditing(_ force: Bool)
    func setupViewModel(
        _ viewModel: BankCardRepeatViewModel
    )
    func setConfirmButtonEnabled(_ isEnabled: Bool)
    func setSavePaymentMethodViewModel(
        _ savePaymentMethodViewModel: SavePaymentMethodViewModel
    )
    func showPlaceholder(with message: String)
    func setCardState(_ state: MaskedCardView.CscState)
}

protocol BankCardRepeatViewOutput: ActionTitleTextDialogDelegate {
    func setupView()
    func didTapActionButton()
    func didTapTermsOfService(_ url: URL)
    func didTapSafeDealInfo(_ url: URL)
    func didTapOnSavePaymentMethod()
    func didChangeSavePaymentMethodState(_ state: Bool)
    func didSetCsc(_ csc: String)
    func endEditing()
}
