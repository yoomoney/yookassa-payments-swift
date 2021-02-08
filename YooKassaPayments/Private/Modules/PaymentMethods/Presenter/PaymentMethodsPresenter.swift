import YooKassaPaymentsApi
import MoneyAuth

final class PaymentMethodsPresenter {

    // MARK: - VIPER

    var interactor: PaymentMethodsInteractorInput!
    var router: PaymentMethodsRouterInput!
    var moduleOutput: PaymentMethodsModuleOutput?
    
    weak var view: PaymentMethodsViewInput?

    // MARK: - Init data

    private let isLogoVisible: Bool
    private let paymentMethodViewModelFactory: PaymentMethodViewModelFactory
    
    private let clientApplicationKey: String
    private let testModeSettings: TestModeSettings?
    private let isLoggingEnabled: Bool
    private let moneyAuthClientId: String?
    private let tokenizationSettings: TokenizationSettings
    
    private let moneyAuthConfig: MoneyAuth.Config
    private let moneyAuthCustomization: MoneyAuth.Customization
    
    private let shopName: String
    private let purchaseDescription: String
    private let returnUrl: String?
    private let savePaymentMethod: SavePaymentMethod

    // MARK: - Init

    init(
        isLogoVisible: Bool,
        paymentMethodViewModelFactory: PaymentMethodViewModelFactory,
        clientApplicationKey: String,
        testModeSettings: TestModeSettings?,
        isLoggingEnabled: Bool,
        moneyAuthClientId: String?,
        tokenizationSettings: TokenizationSettings,
        moneyAuthConfig: MoneyAuth.Config,
        moneyAuthCustomization: MoneyAuth.Customization,
        shopName: String,
        purchaseDescription: String,
        returnUrl: String?,
        savePaymentMethod: SavePaymentMethod
    ) {
        self.isLogoVisible = isLogoVisible
        self.paymentMethodViewModelFactory = paymentMethodViewModelFactory
        
        self.clientApplicationKey = clientApplicationKey
        self.testModeSettings = testModeSettings
        self.isLoggingEnabled = isLoggingEnabled
        self.moneyAuthClientId = moneyAuthClientId
        self.tokenizationSettings = tokenizationSettings
        
        self.moneyAuthConfig = moneyAuthConfig
        self.moneyAuthCustomization = moneyAuthCustomization
        
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.returnUrl = returnUrl
        self.savePaymentMethod = savePaymentMethod
    }

    // MARK: - Stored properties

    fileprivate var moneyAuthCoordinator: MoneyAuth.AuthorizationCoordinator?
    fileprivate var tmxSessionId: String?

    fileprivate var paymentMethods: [PaymentOption]?
    
    private lazy var termsOfService: TermsOfService = {
        TermsOfServiceFactory.makeTermsOfService()
    }()
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
        guard let paymentMethods = paymentMethods,
              indexPath.row < paymentMethods.count else {
            return
        }
        
        let paymentOption = paymentMethods[indexPath.row]
        if let paymentOption = paymentOption as? PaymentInstrumentYooMoneyWallet {
            openYooMoneyWallet(paymentOption: paymentOption)
        } else if paymentOption.paymentMethodType == .yooMoney {
            if self.testModeSettings != nil {
                view?.showActivity()
                DispatchQueue.global().async {
                    self.interactor.fetchYooMoneyPaymentMethods(
                        moneyCenterAuthToken: "MOCK_TOKEN"
                    )
                }
            } else {
                do {
                    moneyAuthCoordinator = try router.presentYooMoneyAuthorizationModule(
                        config: moneyAuthConfig,
                        customization: moneyAuthCustomization,
                        output: self
                    )
                    let event = AnalyticsEvent.userStartAuthorization
                    self.interactor.trackEvent(event)
                } catch {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.view?.showActivity()
                        DispatchQueue.global().async { [weak self] in
                            self?.interactor.fetchPaymentMethods()
                        }
                    }
                    
                    let event = AnalyticsEvent.userCancelAuthorization
                    self.interactor.trackEvent(event)
                }
            }
        } else {
            moduleOutput?.paymentMethodsModule(
                self,
                didSelect: paymentMethods[indexPath.row],
                methodsCount: paymentMethods.count
            )
        }
    }

    func logoutDidPress(
        at indexPath: IndexPath
    ) {
        guard let paymentMethods = paymentMethods,
              indexPath.row < paymentMethods.count,
              let paymentOption = paymentMethods[indexPath.row] as? PaymentInstrumentYooMoneyWallet else { return }
        moduleOutput?.paymentMethodsModule(self, didPressLogout: paymentOption)
    }
    
    private func openYooMoneyWallet(
        paymentOption: PaymentInstrumentYooMoneyWallet
    ) {
        let walletDisplayName = interactor.getWalletDisplayName()
        let paymentMethod = paymentMethodViewModelFactory.makePaymentMethodViewModel(
            paymentOption: paymentOption,
            walletDisplayName: walletDisplayName
        )
        let tokenizeScheme = TokenizeSchemeFactory.makeTokenizeScheme(paymentOption)
        let initialSavePaymentMethod = makeInitialSavePaymentMethod(savePaymentMethod)
        let savePaymentMethodViewModel =  SavePaymentMethodViewModelFactory.makeSavePaymentMethodViewModel(
            paymentOption,
            savePaymentMethod,
            initialState: initialSavePaymentMethod
        )
        let inputData = YooMoneyModuleInputData(
            clientApplicationKey: clientApplicationKey,
            testModeSettings: testModeSettings,
            isLoggingEnabled: isLoggingEnabled,
            moneyAuthClientId: moneyAuthClientId,
            tokenizationSettings: tokenizationSettings,
            shopName: shopName,
            purchaseDescription: purchaseDescription,
            price: makePriceViewModel(paymentOption),
            fee: makeFeePriceViewModel(paymentOption),
            paymentMethod: paymentMethod,
            paymentOption: paymentOption,
            tokenizeScheme: tokenizeScheme,
            termsOfService: termsOfService,
            returnUrl: returnUrl,
            savePaymentMethodViewModel: savePaymentMethodViewModel,
            tmxSessionId: tmxSessionId,
            initialSavePaymentMethod: initialSavePaymentMethod
        )
        router?.presentYooMoney(
            inputData: inputData,
            moduleOutput: self
        )
    }
}

// MARK: - ActionTitleTextDialogDelegate

extension PaymentMethodsPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(
        in actionTitleTextDialog: ActionTitleTextDialog
    ) {
        guard let view = view else { return }
        view.hidePlaceholder()
        view.showActivity()
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.interactor.fetchPaymentMethods()
        }
    }
}

// MARK: - PaymentMethodsModuleInput

extension PaymentMethodsPresenter: PaymentMethodsModuleInput {}

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
                // TODO: - Open only first. https://jira.yamoney.ru/browse/MOC-1645
                self.moduleOutput?.paymentMethodsModule(
                    self,
                    didSelect: paymentMethod,
                    methodsCount: paymentMethods.count
                )
            } else {
                let walletDisplayName = self.interactor.getWalletDisplayName()
                let viewModels = paymentMethods.map {
                    self.paymentMethodViewModelFactory.makePaymentMethodViewModel(
                        paymentOption: $0,
                        walletDisplayName: walletDisplayName
                    )
                }
                view.hideActivity()
                view.setPaymentMethodViewModels(viewModels)
            }
        }
    }

    func didFetchPaymentMethods(_ error: Error) {
        presentError(error)
    }
    
    func didFetchYooMoneyPaymentMethods(
        _ paymentMethods: [PaymentOption]
    ) {
        
        let condition: (PaymentOption) -> Bool = { $0 is PaymentInstrumentYooMoneyWallet }

        if let paymentOption = paymentMethods.first as? PaymentInstrumentYooMoneyWallet,
           paymentMethods.count == 1 {
            // TODO: - Open only YooMoney without payment methods. https://jira.yamoney.ru/browse/MOC-1645
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view?.hideActivity()
                self.openYooMoneyWallet(paymentOption: paymentOption)
            }
        } else if paymentMethods.contains(where: condition) == false {
            // TODO: - Need present error no wallet
            interactor.fetchPaymentMethods()
//            DispatchQueue.main.async { [weak self] in
//                guard let view = self?.view else { return }
//                view.hideActivity()
//                view.showPlaceholder(message: §Localized.noWalletTitle)
//            }
        } else {
            interactor.fetchPaymentMethods()
        }
    }

    func didFetchYooMoneyPaymentMethods(_ error: Error) {
        presentError(error)
    }
    
    private func presentError(_ error: Error) {
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

// MARK: - ProcessCoordinatorDelegate

extension PaymentMethodsPresenter: AuthorizationCoordinatorDelegate {
    func authorizationCoordinator(
        _ coordinator: AuthorizationCoordinator,
        didAcquireAuthorizationToken token: String,
        account: UserAccount,
        authorizationProcess: AuthorizationProcess?,
        tmxSessionId: String?,
        phoneOffersAccepted: Bool,
        emailOffersAccepted: Bool,
        userAgreementAccepted: Bool
    ) {
        self.moneyAuthCoordinator = nil
        self.tmxSessionId = tmxSessionId

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.closeAuthorizationModule()

            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                self.interactor.setAccount(account)
                self.interactor.fetchYooMoneyPaymentMethods(
                    moneyCenterAuthToken: token
                )

                let event: AnalyticsEvent
                switch authorizationProcess {
                case .login:
                    event = .userSuccessAuthorization(.login)
                case .enrollment:
                    event = .userSuccessAuthorization(.enrollment)
                case .migration:
                    event = .userSuccessAuthorization(.migration)
                case .none:
                    event = .userSuccessAuthorization(.unknown)
                }
                self.interactor.trackEvent(event)
            }
        }
    }

    func authorizationCoordinatorDidCancel(
        _ coordinator: AuthorizationCoordinator
    ) {
        self.moneyAuthCoordinator = nil

        let event = AnalyticsEvent.userCancelAuthorization
        interactor.trackEvent(event)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.router.shouldDismissAuthorizationModule() {
                self.router.closeAuthorizationModule()
            }
            self.view?.showActivity()
            DispatchQueue.global().async { [weak self] in
                self?.interactor.fetchPaymentMethods()
            }
        }
    }

    func authorizationCoordinator(
        _ coordinator: AuthorizationCoordinator,
        didFailureWith error: Error
    ) {
        self.moneyAuthCoordinator = nil

        let event = AnalyticsEvent.userFailedAuthorization(
            error.localizedDescription
        )
        interactor.trackEvent(event)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.closeAuthorizationModule()
            self.view?.showActivity()
            DispatchQueue.global().async { [weak self] in
                self?.interactor.fetchPaymentMethods()
            }
        }
    }

    func authorizationCoordinatorDidPrepareProcess(
        _ coordinator: AuthorizationCoordinator
    ) {}

    func authorizationCoordinator(
        _ coordinator: AuthorizationCoordinator,
        didFailPrepareProcessWithError error: Error
    ) {}
}

// MARK: - YooMoneyModuleOutput

extension PaymentMethodsPresenter: YooMoneyModuleOutput {
    func didLogout(
        _ module: YooMoneyModuleInput
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.closeYooMoneyModule()
            self.view?.showActivity()
            DispatchQueue.global().async { [weak self] in
                self?.interactor.fetchPaymentMethods()
            }
        }
    }
    
    func tokenizationModule(
        _ module: YooMoneyModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    ) {
        moduleOutput?.tokenizationModule(
            self,
            didTokenize: token,
            paymentMethodType: paymentMethodType
        )
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

// MARK: - Private global helpers

private func makePriceViewModel(
    _ paymentOption: PaymentOption
) -> PriceViewModel {
    let amountString = paymentOption.charge.value.description
    var integerPart = ""
    var fractionalPart = ""

    if let separatorIndex = amountString.firstIndex(of: ".") {
        integerPart = String(amountString[amountString.startIndex..<separatorIndex])
        fractionalPart = String(amountString[amountString.index(after: separatorIndex)..<amountString.endIndex])
    } else {
        integerPart = amountString
        fractionalPart = "00"
    }
    let currency = Currency(rawValue: paymentOption.charge.currency)
        ?? Currency.custom(paymentOption.charge.currency)
    return TempAmount(
        currency: currency.symbol,
        integerPart: integerPart,
        fractionalPart: fractionalPart,
        style: .amount
    )
}

private func makeFeePriceViewModel(
    _ paymentOption: PaymentOption
) -> PriceViewModel? {
    guard let fee = paymentOption.fee,
          let service = fee.service else { return nil }

    let amountString = service.charge.value.description
    var integerPart = ""
    var fractionalPart = ""

    if let separatorIndex = amountString.firstIndex(of: ".") {
        integerPart = String(amountString[amountString.startIndex..<separatorIndex])
        fractionalPart = String(amountString[amountString.index(after: separatorIndex)..<amountString.endIndex])
    } else {
        integerPart = amountString
        fractionalPart = "00"
    }
    let currency = Currency(rawValue: service.charge.currency)
        ?? Currency.custom(service.charge.currency)
    return TempAmount(
        currency: currency.symbol,
        integerPart: integerPart,
        fractionalPart: fractionalPart,
        style: .fee
    )
}

private func makeInitialSavePaymentMethod(
    _ savePaymentMethod: SavePaymentMethod
) -> Bool {
    let initialSavePaymentMethod: Bool
    switch savePaymentMethod {
    case .on:
        initialSavePaymentMethod = true
    case .off, .userSelects:
        initialSavePaymentMethod = false
    }
    return initialSavePaymentMethod
}
