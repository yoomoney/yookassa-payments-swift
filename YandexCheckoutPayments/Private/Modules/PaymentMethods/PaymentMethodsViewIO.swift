import UIKit.UIImage
import YandexCheckoutPaymentsApi

private enum PaymentMethodViewModelHelper {
    static var balanceNumberFormatter: NumberFormatter = {
        $0.locale = .current
        $0.numberStyle = .currency
        return $0
    }(NumberFormatter())

    enum Localized: String {
        case change = "Contract.changePaymentMethod"
    }
}

protocol PaymentMethodViewModel {
    var name: String { get }
    var image: UIImage { get }
    var balance: MonetaryAmount? { get }

}

extension PaymentMethodViewModel {
    var balanceText: String? {
        guard let balance = balance else {
            return nil
        }

        let balanceNumberFormatter = PaymentMethodViewModelHelper.balanceNumberFormatter

        balanceNumberFormatter.currencySymbol = String(balance.currency.currencySymbol)

        return balanceNumberFormatter.string(for: balance.value)
    }

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

protocol PaymentMethodsViewOutput: ActionTextDialogDelegate {
    func setupView()
    func viewDidAppear()
    func didSelectViewModel(_ viewModel: PaymentMethodViewModel, at indexPath: IndexPath)
    func logoutDidPress(at indexPath: IndexPath)
}
