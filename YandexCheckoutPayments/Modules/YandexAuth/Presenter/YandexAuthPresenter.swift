import struct Foundation.IndexPath
import class YandexCheckoutPaymentsApi.PaymentOption
import class YandexCheckoutPaymentsApi.PaymentInstrumentYandexMoneyWallet
import class Dispatch.DispatchQueue

final class YandexAuthPresenter {

    // MARK: - VIPER module properties

    var interactor: YandexAuthInteractorInput!

    weak var view: PaymentMethodsViewInput?
    weak var moduleOutput: YandexAuthModuleOutput?
}

// MARK: - PaymentMethodsViewOutput

extension YandexAuthPresenter: PaymentMethodsViewOutput {

    func setupView() {

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.showActivity()
            view.setPlaceholderViewButtonTitle(§Localized.noWalletButtonTitle)

            DispatchQueue.global().async { [weak self] in
                guard let interactor = self?.interactor else { return }
                interactor.authorizeInYandex()
            }
        }
    }

    func didSelectViewModel(_ viewModel: PaymentMethodViewModel, at indexPath: IndexPath) {}
    func logoutDidPress(at indexPath: IndexPath) {}
}

// MARK: - ActionTextDialogDelegate

extension YandexAuthPresenter: ActionTextDialogDelegate {
    func didPressButton() {
        guard let view = view else { return }
        view.hidePlaceholder()
        view.showActivity()
        moduleOutput?.didFetchYamoneyPaymentMethodsWithoutWallet(on: self)
    }
}

// MARK: - YandexAuthInteractorOutput

extension YandexAuthPresenter: YandexAuthInteractorOutput {
    func didAuthorizeInYandex(token: String) {

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }

            view.showActivity()

            DispatchQueue.global().async { [weak self] in
                guard let interactor = self?.interactor else { return }
                interactor.trackEvent(.actionYaLoginAuthorization(.success))
                interactor.fetchYamoneyPaymentMethods()
            }
        }
    }

    func didAuthorizeInYandex(error: Error) {
        if case YandexLoginProcessingError.applicationDidBecomeActive = error {
            moduleOutput?.didCancelAuthorizeInYandex(on: self)

        } else if case YandexLoginProcessingError.accessDenied = error {
            moduleOutput?.didCancelAuthorizeInYandex(on: self)

            DispatchQueue.global().async { [weak self] in
                guard let interactor = self?.interactor else { return }
                interactor.trackEvent(.actionYaLoginAuthorization(.canceled))
            }

        } else {
            DispatchQueue.global().async { [weak self] in
                guard let interactor = self?.interactor else { return }
                interactor.trackEvent(.actionYaLoginAuthorization(.fail))
            }
        }
    }

    func didFetchYamoneyPaymentMethods(_ paymentMethods: [PaymentOption]) {

        let condition: (PaymentOption) -> Bool = { $0 is PaymentInstrumentYandexMoneyWallet }

        if let paymentOption = paymentMethods.first as? PaymentInstrumentYandexMoneyWallet,
           paymentMethods.count == 1 {

            moduleOutput?.yandexAuthModule(self, didFetchYamoneyPaymentMethod: paymentOption)

        } else if paymentMethods.contains(where: condition) == false {

            DispatchQueue.main.async { [weak self] in
                guard let view = self?.view else { return }
                view.hideActivity()
                view.showPlaceholder(message: §Localized.noWalletTitle)
            }

        } else {

            moduleOutput?.didFetchYamoneyPaymentMethods(on: self)

        }
    }

    func didFetchYamoneyPaymentMethods(_ error: Error) {
        moduleOutput?.didFailFetchYamoneyPaymentMethods(on: self)
    }
}

// MARK: - YandexAuthModuleInput

extension YandexAuthPresenter: YandexAuthModuleInput {}

// MARK: - Localized

private extension YandexAuthPresenter {

    enum Localized: String {
        case noWalletTitle = "PaymentOptionsNoWallet.title"
        case noWalletButtonTitle = "PaymentOptionsNoWallet.buttonTitle"
    }
}
