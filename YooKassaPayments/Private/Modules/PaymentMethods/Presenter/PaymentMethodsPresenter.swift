import YooKassaPaymentsApi

final class PaymentMethodsPresenter {

    // MARK: - VIPER

    weak var view: PaymentMethodsViewInput?
    weak var moduleOutput: PaymentMethodsModuleOutput?
    var interactor: PaymentMethodsInteractorInput!

    // MARK: - Init data

    fileprivate let isLogoVisible: Bool
    fileprivate let paymentMethodViewModelFactory: PaymentMethodViewModelFactory

    // MARK: - Init

    init(
        isLogoVisible: Bool,
        paymentMethodViewModelFactory: PaymentMethodViewModelFactory
    ) {
        self.isLogoVisible = isLogoVisible
        self.paymentMethodViewModelFactory = paymentMethodViewModelFactory
    }

    // MARK: - Properties

    fileprivate var paymentMethods: [PaymentOption]?
}

// MARK: - PaymentMethodsViewOutput

extension PaymentMethodsPresenter: PaymentMethodsViewOutput {
    func setupView() {
        guard let view = self.view else { return }
        view.showActivity()
        view.setLogoVisible(isLogoVisible)
        view.setPlaceholderViewButtonTitle(§Localized.PlaceholderView.buttonTitle)
    }

    func viewDidAppear() {
        DispatchQueue.global().async { [weak self] in
            self?.interactor.fetchPaymentMethods()
        }
    }

    func didSelectViewModel(
        _ viewModel: PaymentMethodViewModel,
        at indexPath: IndexPath
    ) {
        guard let paymentMethods = paymentMethods, indexPath.row < paymentMethods.count else { return }
        moduleOutput?.paymentMethodsModule(
            self,
            didSelect: paymentMethods[indexPath.row],
            methodsCount: paymentMethods.count
        )
    }

    func logoutDidPress(
        at indexPath: IndexPath
    ) {
        guard let paymentMethods = paymentMethods,
              indexPath.row < paymentMethods.count,
              let paymentOption = paymentMethods[indexPath.row] as? PaymentInstrumentYooMoneyWallet else { return }
        moduleOutput?.paymentMethodsModule(self, didPressLogout: paymentOption)
    }
}

// MARK: - PlaceholderViewDelegate

extension PaymentMethodsPresenter: ActionTextDialogDelegate {
    // This is button in placeholder view. Need fix in UI library
    func didPressButton() {
        guard let view = view else { return }
        interactor.fetchPaymentMethods()
        view.hidePlaceholder()
        view.showActivity()
    }
}

// MARK: - PaymentMethodsModuleInput

extension PaymentMethodsPresenter: PaymentMethodsModuleInput {

    func showPlaceholder(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let view = self.view else { return }
            view.showPlaceholder(message: message)
        }
    }

    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.setupView()
            DispatchQueue.global().async {
                self.interactor.fetchPaymentMethods()
            }
        }
    }

    func yooMoneyAuthModule(
        _ module: YooMoneyAuthModuleInput,
        didSelectViewModel viewModel: PaymentMethodViewModel,
        at indexPath: IndexPath
    ) {
        didSelectViewModel(viewModel, at: indexPath)
    }
}

// MARK: - PaymentMethodsInteractorOutput

extension PaymentMethodsPresenter: PaymentMethodsInteractorOutput {
    func didFetchPaymentMethods(_ paymentMethods: [PaymentOption]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let view = self.view else { return }

            let (authType, _) = self.interactor.makeTypeAnalyticsParameters()
            self.interactor.trackEvent(.screenPaymentOptions(authType))

            self.paymentMethods = paymentMethods

            if paymentMethods.count == 1, let paymentMethod = paymentMethods.first {
                self.moduleOutput?.paymentMethodsModule(
                    self,
                    didSelect: paymentMethod,
                    methodsCount: paymentMethods.count
                )
            } else {
                let viewModels = paymentMethods.map {
                    self.paymentMethodViewModelFactory.makePaymentMethodViewModel(
                        paymentOption: $0
                    )
                }
                view.hideActivity()
                view.setPaymentMethodViewModels(viewModels)
            }
        }
    }

    func didFetchPaymentMethods(_ error: Error) {
        let message: String

        switch error {
        case let error as PresentableError:
            message = error.message
        default:
            message = §CommonLocalized.Error.unknown
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self, let view = self.view else { return }
            view.hideActivity()
            view.showPlaceholder(message: message)

            DispatchQueue.global().async { [weak self] in
                guard let interactor = self?.interactor else { return }
                let (authType, _) = interactor.makeTypeAnalyticsParameters()
                interactor.trackEvent(.screenError(authType: authType, scheme: nil))
            }
        }
    }
}

// MARK: - Localized

private extension PaymentMethodsPresenter {
    enum Localized {
        enum PlaceholderView: String {
            case buttonTitle = "Common.PlaceholderView.buttonTitle"
        }
    }
}
