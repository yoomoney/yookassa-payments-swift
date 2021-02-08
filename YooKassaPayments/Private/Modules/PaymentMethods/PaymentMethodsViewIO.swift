import UIKit.UIImage

private enum PaymentMethodViewModelHelper {
    enum Localized: String {
        case change = "Contract.changePaymentMethod"
    }
}

extension PaymentMethodViewModel {
    var change: String {
        return §PaymentMethodViewModelHelper.Localized.change
    }
}

protocol PaymentMethodsViewInput: ActivityIndicatorFullViewPresenting {
    func setLogoVisible(_ isVisible: Bool)
    func setPaymentMethodViewModels(_ models: [PaymentMethodViewModel])
    func setPlaceholderViewButtonTitle(_ title: String)

    func showPlaceholder(message: String)
    func hidePlaceholder()
}

protocol PaymentMethodsViewOutput: ActionTitleTextDialogDelegate {
    func setupView()
    func viewDidAppear()
    func didSelectViewModel(_ viewModel: PaymentMethodViewModel, at indexPath: IndexPath)
    func logoutDidPress(at indexPath: IndexPath)
}
