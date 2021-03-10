import UIKit

protocol BankCardViewInput: ActivityIndicatorPresenting, NotificationPresenting {
    func setViewModel(
        _ viewModel: BankCardViewModel
    )
    func setSubmitButtonEnabled(
        _ isEnabled: Bool
    )
    func endEditing(
        _ force: Bool
    )
    func setSavePaymentMethodViewModel(
        _ savePaymentMethodViewModel: SavePaymentMethodViewModel
    )
    func setBackBarButtonHidden(
        _ isHidden: Bool
    )
}

protocol BankCardViewOutput: class {
    func setupView()
    func didPressSubmitButton()
    func didTapTermsOfService(
        _ url: URL
    )
    func didTapOnSavePaymentMethod()
    func didChangeSavePaymentMethodState(
        _ state: Bool
    )
}
