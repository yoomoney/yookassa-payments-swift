import UIKit

protocol BankCardViewInput: ActivityIndicatorPresenting, NotificationPresenting {

    var focus: BankCardView.BankCardFocus? { get set }

    func setViewModel(
        _ viewModel: BankCardViewModel
    )
    func setBankLogoImage(
        _ image: UIImage?
    )
    func setCardViewMode(
        _ mode: InputPanCardView.RightButtonMode
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
    func setPanValue(
        _ value: String
    )
    func setExpiryDateValue(
        _ value: String
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
    func scanDidPress()
    func didChangePan(
        _ value: String
    )
    func didChangeExpiryDate(
        _ value: String
    )
    func didChangeCvc(
        _ value: String
    )
    func didTapOnSavePaymentMethod()
    func didChangeSavePaymentMethodState(
        _ state: Bool
    )
    func panDidBeginEditing()
}
