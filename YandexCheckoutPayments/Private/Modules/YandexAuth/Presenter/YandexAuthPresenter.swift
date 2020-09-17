import struct Foundation.IndexPath
import class YandexCheckoutPaymentsApi.PaymentOption
import class YandexCheckoutPaymentsApi.PaymentInstrumentYandexMoneyWallet
import class Dispatch.DispatchQueue
import MoneyAuth

final class YandexAuthPresenter {

    // MARK: - VIPER module properties

    var interactor: YandexAuthInteractorInput!
    var router: YandexAuthRouterInput!

    weak var view: PaymentMethodsViewInput?
    weak var moduleOutput: YandexAuthModuleOutput?

    // MARK: - Stored properties

    private var moneyAuthCoordinator: MoneyAuth.AuthorizationCoordinator?

    // MARK: - Initialization

    private let testModeSettings: TestModeSettings?

    init(
        testModeSettings: TestModeSettings?
    ) {
        self.testModeSettings = testModeSettings
    }
}

// MARK: - PaymentMethodsViewOutput

extension YandexAuthPresenter: PaymentMethodsViewOutput {

    func setupView() {

        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let view = self.view else { return }
            view.setPlaceholderViewButtonTitle(§Localized.noWalletButtonTitle)

            if self.testModeSettings != nil {
                DispatchQueue.global().async {
                    self.interactor.fetchYamoneyPaymentMethods(
                        moneyCenterAuthToken: "MOCK_TOKEN"
                    )
                }
            } else {
                do {
                    self.moneyAuthCoordinator = try self.router.presentAuthorizationModule(
                        config: self.makeMoneyAuthConfig(),
                        output: self
                    )
                } catch {
                    self.moduleOutput?.didCancelAuthorizeInYandex(on: self)
                }
            }
        }
    }

    func viewDidAppear() {}
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

// MARK: - ProcessCoordinatorDelegate

extension YandexAuthPresenter: AuthorizationCoordinatorDelegate {
    func authorizationCoordinator(
        _ coordinator: AuthorizationCoordinator,
        didAcquireAuthorizationToken token: String
    ) {
        self.moneyAuthCoordinator = nil
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.closeAuthorizationModule()

            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                self.interactor.fetchYamoneyPaymentMethods(
                    moneyCenterAuthToken: token
                )
            }
        }
    }

    func authorizationCoordinatorDidCancel(
        _ coordinator: AuthorizationCoordinator
    ) {
        self.moneyAuthCoordinator = nil
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.closeAuthorizationModule()
            self.moduleOutput?.didCancelAuthorizeInYandex(on: self)
        }
    }

    func authorizationCoordinator(
        _ coordinator: AuthorizationCoordinator,
        didFailureWith error: Error
    ) {
        self.moneyAuthCoordinator = nil
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.closeAuthorizationModule()
            self.moduleOutput?.didCancelAuthorizeInYandex(on: self)
        }
    }

    func authorizationCoordinatorDidPrepareProcess(_ coordinator: AuthorizationCoordinator) {}
    func authorizationCoordinator(_ coordinator: AuthorizationCoordinator, didFailPrepareProcessWithError error: Error) {}
}

// MARK: - Private helpers

private extension YandexAuthPresenter {
    func makeMoneyAuthConfig() -> MoneyAuth.Config {
        let authenticationChallengeHandler: AuthenticationChallengeHandler = { session, challenge, completionHandler in
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.performDefaultHandling, nil)
                return
            }
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }

        let host = ""
        assert(host.isEmpty == false)

        let clientId = ""
        assert(clientId.isEmpty == false)

        let config = MoneyAuth.Config(
            origin: .wallet,
            clientId: clientId,
            host: host,
            isDevHost: true,
            loggingEnabled: true,
            authenticationChallengeHandler: authenticationChallengeHandler,
            setEmailSwitchTitle: nil,
            setPhoneSwitchTitle: nil,
            userAgreement: nil
        )
        return config
    }
}

// MARK: - Localized

private extension YandexAuthPresenter {

    enum Localized: String {
        case noWalletTitle = "PaymentOptionsNoWallet.title"
        case noWalletButtonTitle = "PaymentOptionsNoWallet.buttonTitle"
    }
}
