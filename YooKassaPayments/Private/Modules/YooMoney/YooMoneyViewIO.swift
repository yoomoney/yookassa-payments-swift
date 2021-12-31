import UIKit

struct YooMoneyViewModel {
    let shopName: String
    let description: String?
    let price: PriceViewModel
    let fee: PriceViewModel?
    let paymentMethod: PaymentMethodViewModel
    let terms: NSAttributedString
    let safeDealText: NSAttributedString?
    let paymentOptionTitle: String?
}

protocol YooMoneyViewInput: ActivityIndicatorFullViewPresenting, PlaceholderPresenting, NotificationPresenting {
    func setupViewModel(
        _ viewModel: YooMoneyViewModel
    )
    func setupAvatar(
        _ avatar: UIImage
    )
    func setSavePaymentMethodViewModel(
        _ savePaymentMethodViewModel: SavePaymentMethodViewModel
    )
    func setSaveAuthInAppSwitchItemView()
    func showPlaceholder(with message: String)

    func setBackBarButtonHidden(
        _ isHidden: Bool
    )
}

protocol YooMoneyViewOutput: ActionTitleTextDialogDelegate {
    func setupView()
    func didTapActionButton()
    func didTapLogout()
    func didTapTermsOfService(_ url: URL)
    func didTapSafeDealInfo(_ url: URL)
    func didTapOnSavePaymentMethod()
    func didChangeSavePaymentMethodState(
        _ state: Bool
    )
    func didChangeSaveAuthInAppState(
        _ state: Bool
    )
}
