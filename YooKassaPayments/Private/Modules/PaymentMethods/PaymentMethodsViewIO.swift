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

protocol PaymentMethodsViewInput: ActivityIndicatorFullViewPresenting, NotificationPresenting {
    func reloadData()
    func setLogoVisible(_ isVisible: Bool)

    func showPlaceholder(message: String)
    func hidePlaceholder()
}

protocol PaymentMethodsViewOutput: ActionTitleTextDialogDelegate {
    func setupView()
    func viewDidAppear()
    func numberOfRows() -> Int
    func viewModelForRow(at indexPath: IndexPath) -> PaymentMethodViewModel?
    func didSelect(at indexPath: IndexPath)
}
