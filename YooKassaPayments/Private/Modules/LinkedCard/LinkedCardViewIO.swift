protocol LinkedCardViewInput: ActivityIndicatorPresenting, PlaceholderPresenting, NotificationPresenting {
    func endEditing(_ force: Bool)
    func setupTitle(
        _ title: String?
    )
    func setupViewModel(
        _ viewModel: LinkedCardViewModel
    )
    func setSaveAuthInAppSwitchItemView()
    func setConfirmButtonEnabled(_ isEnabled: Bool)
    func showPlaceholder(with message: String)
    func setCardErrorState(_ state: Bool)
}

protocol LinkedCardViewOutput: ActionTitleTextDialogDelegate {
    func setupView()
    func didTapActionButton()
    func didTapTermsOfService(_ url: URL)
    func didChangeSaveAuthInAppState(
        _ state: Bool
    )
    func didSetCsc(
        _ csc: String
    )
    func endEditing()
}
