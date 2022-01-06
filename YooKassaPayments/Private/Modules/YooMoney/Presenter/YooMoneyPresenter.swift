import YooKassaPaymentsApi

final class YooMoneyPresenter {

    // MARK: - VIPER

    var interactor: YooMoneyInteractorInput!
    var router: YooMoneyRouterInput!

    weak var view: YooMoneyViewInput?
    weak var moduleOutput: YooMoneyModuleOutput?

    // MARK: - Init data

    private let clientApplicationKey: String
    private let testModeSettings: TestModeSettings?
    private let isLoggingEnabled: Bool
    private let moneyAuthClientId: String?

    private let shopName: String
    private let purchaseDescription: String
    private let price: PriceViewModel
    private let fee: PriceViewModel?
    private let paymentMethod: PaymentMethodViewModel
    private let paymentOption: PaymentInstrumentYooMoneyWallet
    private let termsOfService: NSAttributedString
    private let returnUrl: String?
    private let savePaymentMethodViewModel: SavePaymentMethodViewModel?
    private let tmxSessionId: String?
    private var initialSavePaymentMethod: Bool
    private let isBackBarButtonHidden: Bool
    private let isSafeDeal: Bool
    private let paymentOptionTitle: String?

    // MARK: - Init

    init(
        clientApplicationKey: String,
        testModeSettings: TestModeSettings?,
        isLoggingEnabled: Bool,
        moneyAuthClientId: String?,
        shopName: String,
        purchaseDescription: String,
        price: PriceViewModel,
        fee: PriceViewModel?,
        paymentMethod: PaymentMethodViewModel,
        paymentOption: PaymentInstrumentYooMoneyWallet,
        termsOfService: NSAttributedString,
        returnUrl: String?,
        savePaymentMethodViewModel: SavePaymentMethodViewModel?,
        tmxSessionId: String?,
        initialSavePaymentMethod: Bool,
        isBackBarButtonHidden: Bool,
        isSafeDeal: Bool,
        paymentOptionTitle: String?
    ) {
        self.clientApplicationKey = clientApplicationKey
        self.testModeSettings = testModeSettings
        self.isLoggingEnabled = isLoggingEnabled
        self.moneyAuthClientId = moneyAuthClientId

        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.price = price
        self.fee = fee
        self.paymentMethod = paymentMethod
        self.paymentOption = paymentOption
        self.termsOfService = termsOfService
        self.returnUrl = returnUrl
        self.savePaymentMethodViewModel = savePaymentMethodViewModel
        self.tmxSessionId = tmxSessionId
        self.initialSavePaymentMethod = initialSavePaymentMethod
        self.isBackBarButtonHidden = isBackBarButtonHidden
        self.isSafeDeal = isSafeDeal
        self.paymentOptionTitle = paymentOptionTitle
    }

    // MARK: - Properties

    private var isReusableToken = true
}

// MARK: - YooMoneyViewOutput

extension YooMoneyPresenter: YooMoneyViewOutput {
    func setupView() {
        guard let view = view else { return }

        let viewModel = YooMoneyViewModel(
            shopName: shopName,
            description: purchaseDescription,
            price: price,
            fee: fee,
            paymentMethod: paymentMethod,
            terms: termsOfService,
            safeDealText: isSafeDeal ? PaymentMethodResources.Localized.safeDealInfoLink : nil,
            paymentOptionTitle: paymentOptionTitle
        )
        view.setupViewModel(viewModel)

        if !interactor.hasReusableWalletToken() {
            view.setSaveAuthInAppSwitchItemView()
        }

        if let savePaymentMethodViewModel = savePaymentMethodViewModel {
            view.setSavePaymentMethodViewModel(
                savePaymentMethodViewModel
            )
        }

        view.setBackBarButtonHidden(isBackBarButtonHidden)

        DispatchQueue.global().async { [weak self] in
            guard let self = self, let interactor = self.interactor else { return }
            interactor.loadAvatar()

            interactor.track(event:
                .screenPaymentContract(
                    scheme: .wallet,
                    currentAuthType: self.interactor.analyticsAuthType()
                )
            )
        }
    }

    func didTapActionButton() {
        view?.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            if self.interactor.hasReusableWalletToken() {
                self.tokenize()
            } else {
                self.interactor.loginInWallet(
                    amount: self.paymentOption.charge.plain,
                    reusableToken: self.isReusableToken,
                    tmxSessionId: self.tmxSessionId
                )
            }
        }
    }

    func didTapLogout() {
        let walletDisplayName = interactor.getWalletDisplayName()
        let inputData = LogoutConfirmationModuleInputData(
            accountName: walletDisplayName ?? paymentOption.accountId
        )
        router.presentLogoutConfirmation(
            inputData: inputData,
            moduleOutput: self
        )
    }

    func didTapTermsOfService(_ url: URL) {
        router.presentTermsOfServiceModule(url)
    }

    func didTapSafeDealInfo(_ url: URL) {
        router.presentSafeDealInfo(
            title: PaymentMethodResources.Localized.safeDealInfoTitle,
            body: PaymentMethodResources.Localized.safeDealInfoBody
        )
    }

    func didTapOnSavePaymentMethod() {
        let savePaymentMethodModuleInputData = SavePaymentMethodInfoModuleInputData(
            headerValue: SavePaymentMethodInfoLocalization.Wallet.header,
            bodyValue: SavePaymentMethodInfoLocalization.Wallet.body
        )
        router.presentSavePaymentMethodInfo(
            inputData: savePaymentMethodModuleInputData
        )
    }

    func didChangeSavePaymentMethodState(_ state: Bool) {
        initialSavePaymentMethod = state
    }

    func didChangeSaveAuthInAppState(_ state: Bool) {
        isReusableToken = state
    }
}

// MARK: - ActionTitleTextDialogDelegate

extension YooMoneyPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(in actionTitleTextDialog: ActionTitleTextDialog) {
        guard let view = view else { return }
        view.hidePlaceholder()
        view.showActivity()

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.tokenize()
        }
    }
}

// MARK: - YooMoneyInteractorOutput

extension YooMoneyPresenter: YooMoneyInteractorOutput {
    func didLoginInWallet(_ response: WalletLoginResponse) {
        switch response {
        case .authorized:
            tokenize()
            interactor.track(event: .actionAuthFinished)
        case let .notAuthorized(
                authTypeState: authTypeState,
                processId: processId,
                authContextId: authContextId
        ):
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view?.hideActivity()

                let inputData = PaymentAuthorizationModuleInputData(
                    clientApplicationKey: self.clientApplicationKey,
                    testModeSettings: self.testModeSettings,
                    isLoggingEnabled: self.isLoggingEnabled,
                    moneyAuthClientId: self.moneyAuthClientId,
                    authContextId: authContextId,
                    processId: processId,
                    tokenizeScheme: .wallet,
                    authTypeState: authTypeState
                )
                self.router.presentPaymentAuthorizationModule(
                    inputData: inputData,
                    moduleOutput: self
                )
            }
        }
    }

    func failLoginInWallet(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.hideActivity()

            let message = makeMessage(error)
            self.view?.presentError(with: message)

            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                self.interactor.track(event:
                    .screenErrorContract(
                        scheme: .wallet,
                        currentAuthType: self.interactor.analyticsAuthType()
                    )
                )
            }
        }
    }

    func didTokenizeData(_ token: Tokens) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.hideActivity()
            self.moduleOutput?.tokenizationModule(
                self,
                didTokenize: token,
                paymentMethodType: self.paymentOption.paymentMethodType.plain
            )

            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }

                self.interactor.track(event:
                    .actionTokenize(
                        scheme: .wallet,
                        currentAuthType: self.interactor.analyticsAuthType()
                    )
                )
            }
        }
    }

    func failTokenizeData(_ error: Error) {
        let message = makeMessage(error)

        interactor.track(
            event: .screenErrorContract(scheme: .wallet, currentAuthType: interactor.analyticsAuthType())
        )
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.showPlaceholder(with: message)
        }
    }

    func didLoadAvatar(_ avatar: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.setupAvatar(avatar)
        }
    }

    func didFailLoadAvatar(_ error: Error) {}

    private func tokenize() {
        interactor.track(event: .actionTryTokenize(scheme: .wallet, currentAuthType: interactor.analyticsAuthType()))
        interactor.tokenize(
            confirmation: Confirmation(type: .redirect, returnUrl: returnUrl),
            savePaymentMethod: initialSavePaymentMethod,
            paymentMethodType: paymentOption.paymentMethodType.plain,
            amount: paymentOption.charge.plain,
            tmxSessionId: tmxSessionId
        )
    }
}

// MARK: - PaymentAuthorizationModuleOutput

extension YooMoneyPresenter: PaymentAuthorizationModuleOutput {
    func didCheckUserAnswer(_ module: PaymentAuthorizationModuleInput, response: WalletLoginResponse) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.closePaymentAuthorization()
            self.view?.showActivity()
            self.didLoginInWallet(response)
        }
    }
}

// MARK: - LogoutConfirmationModuleOutput

extension YooMoneyPresenter: LogoutConfirmationModuleOutput {
    func logoutDidConfirm(on module: LogoutConfirmationModuleInput) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.interactor.logout()
            self.interactor.track(event: .actionLogout)
            self.moduleOutput?.didLogout(self)
        }
    }

    func logoutDidCancel(on module: LogoutConfirmationModuleInput) {}
}

// MARK: - YooMoneyModuleInput

extension YooMoneyPresenter: YooMoneyModuleInput {}

// MARK: - Make message from Error

private func makeMessage(_ error: Error) -> String {
    let message: String

    switch error {
    case let error as PresentableError:
        message = error.message
    default:
        message = CommonLocalized.Error.unknown
    }

    return message
}
