import UIKit

protocol BankCardViewInput: ActivityIndicatorPresenting, NotificationPresenting {
    func setViewModel(_ viewModel: BankCardViewModel)
    func setSubmitButtonEnabled(_ isEnabled: Bool)
    func endEditing(_ force: Bool)
    func setBackBarButtonHidden(_ isHidden: Bool)
    func setCardState(_ state: MaskedCardView.CscState)
}

protocol BankCardViewOutput: AnyObject {
    func setupView()
    func didPressSubmitButton()
    func didTapTermsOfService(_ url: URL)
    func didTapSafeDealInfo(_ url: URL)
    func didTapOnSavePaymentMethod()
    func didSetCsc(_ csc: String)
    func endEditing()
}
