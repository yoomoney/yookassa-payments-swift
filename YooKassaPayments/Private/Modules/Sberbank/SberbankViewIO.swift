protocol SberbankViewOutput:
    ActionTitleTextDialogDelegate,
    PhoneNumberInputModuleOutput
{
    func setupView()
    func didPressSubmitButton()
    func didPressTermsOfService(
        _ url: URL
    )
}

protocol SberbankViewInput:
    ActivityIndicatorFullViewPresenting,
    PlaceholderPresenting,
    NotificationPresenting
{
    func setViewModel(
        _ viewModel: SberbankViewModel
    )
    func setSubmitButtonEnabled(
        _ isEnabled: Bool
    )
    func showPlaceholder(
        with message: String
    )

    func endEditing(
        _ force: Bool
    )

    func setBackBarButtonHidden(
        _ isHidden: Bool
    )
}
