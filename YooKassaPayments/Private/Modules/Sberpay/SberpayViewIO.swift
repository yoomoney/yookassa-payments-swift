protocol SberpayViewInput: ActivityIndicatorFullViewPresenting,
    PlaceholderPresenting,
    NotificationPresenting {
    func setupViewModel(
        _ viewModel: SberpayViewModel
    )
    func setBackBarButtonHidden(
        _ isHidden: Bool
    )
    func showPlaceholder(
        with message: String
    )
}

protocol SberpayViewOutput: ActionTitleTextDialogDelegate {
    func setupView()
    func didTapActionButton()
    func didTapTermsOfService(_ url: URL)
}
