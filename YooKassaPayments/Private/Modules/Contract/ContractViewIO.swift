import class UIKit.UIImage
import struct YooKassaPaymentsApi.MonetaryAmount

enum ContractPlaceholderState {
    case message(String)
    case failResendSmsCode
    case authCheckInvalidContext(message: String, error: Error)
    case sessionBroken(message: String, error: Error)
    case verifyAttemptsExceeded(message: String, error: Error)
    case executeError(message: String, error: Error)
}

protocol ContractViewModel {
    var name: String { get }
    var image: UIImage { get }
    var balance: MonetaryAmount? { get }
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
