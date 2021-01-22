import class UIKit.UIImage

enum ContractPlaceholderState {
    case message(String)
    case failResendSmsCode
    case authCheckInvalidContext(message: String, error: Error)
    case sessionBroken(message: String, error: Error)
    case verifyAttemptsExceeded(message: String, error: Error)
    case executeError(message: String, error: Error)
}

protocol ContractViewInput: ActivityIndicatorFullViewPresenting, PlaceholderPresenting {
    func showPlaceholder(state: ContractPlaceholderState)
    func endEditing(_ force: Bool)
}

protocol ContractViewOutput: LargeIconItemViewOutput,
    IconButtonItemViewOutput,
    LargeIconButtonItemViewOutput,
    ActionTextDialogDelegate {
    func setupView()
}
