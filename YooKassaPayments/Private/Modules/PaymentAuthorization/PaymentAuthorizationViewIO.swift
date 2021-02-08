protocol PaymentAuthorizationViewInput: PlaceholderPresenting, ActivityIndicatorPresenting {
    func endEditing()
    func setCodeLength(_ length: Int)
    func clearCode()
    func setCodeError(_ error: String?)
    func setDescription(_ description: String)
    func setDescriptionError(_ description: String)
    func setRemainingTimeText(_ text: String)
    func setResendCodeButtonTitle(_ title: String)
    func setResendCodeButtonIsEnabled(_ isEnabled: Bool)
    func setResendCodeButtonHidden(_ isHidden: Bool)
    func showPlaceholder(title: String)
}

protocol PaymentAuthorizationViewOutput: ActionTitleTextDialogDelegate {
    func setupView()

    func didGetCode(_ code: String)
    func didPressResendCode()
    func didPressCloseButton()
}
