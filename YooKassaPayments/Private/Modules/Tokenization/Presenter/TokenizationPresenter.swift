import PassKit
import YooKassaPaymentsApi

class TokenizationPresenter: NSObject { // NSObject needs for PKPaymentAuthorizationViewControllerDelegate

    // MARK: - VIPER

    var router: TokenizationRouterInput!
    var interactor: TokenizationInteractorInput!
    weak var moduleOutput: TokenizationModuleOutput?
    weak var view: TokenizationViewInput?

    // MARK: - Init data

    private let inputData: TokenizationModuleInputData
    private let paymentMethodViewModelFactory: PaymentMethodViewModelFactory

    // MARK: - Init

    init(
        inputData: TokenizationModuleInputData,
        paymentMethodViewModelFactory: PaymentMethodViewModelFactory
    ) {
        self.inputData = inputData
        self.paymentMethodViewModelFactory = paymentMethodViewModelFactory
    }

    // MARK: - Properties

    private var paymentOptionsCount: Int = 0
    private var strategy: TokenizationStrategyInput?
    private var tokenizeData: TokenizeData?
    private var isReusableToken: Bool?
    private var tmxSessionId: String?

    private var paymentOption: PaymentOption? {
        didSet {
            strategy = paymentOption.map {
                makeStrategy(
                    paymentOption: $0,
                    output: self,
                    testModeSettings: inputData.testModeSettings,
                    returnUrl: inputData.returnUrl ?? Constants.returnUrl,
                    isLoggingEnabled: inputData.isLoggingEnabled,
                    savePaymentMethod: inputData.savePaymentMethod,
                    moneyAuthClientId: inputData.moneyAuthClientId
                )
            }
        }
    }

    private var shouldChangePaymentOptions: Bool {
        return paymentOptionsCount > Constants.minimalRecommendedPaymentsOptions
    }

    private var paymentMethodViewModel: PaymentMethodViewModel? {
        return paymentOption.map(makePaymentMethodViewModel)
    }

    private lazy var termsOfService: TermsOfService = {
        TermsOfServiceFactory.makeTermsOfService()
    }()

    private func makePaymentMethodViewModel(paymentOption: PaymentOption) -> PaymentMethodViewModel {
        let walletDisplayName = interactor.getWalletDisplayName()
        return paymentMethodViewModelFactory.makePaymentMethodViewModel(
            paymentOption: paymentOption,
            walletDisplayName: walletDisplayName
        )
    }
}

// MARK: - Modules presenting

extension TokenizationPresenter: TokenizationStrategyOutput {
    func presentPaymentMethodsModule() {
        let paymentMethodsInputData = PaymentMethodsModuleInputData(
            clientApplicationKey: inputData.clientApplicationKey,
            gatewayId: inputData.gatewayId,
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            amount: inputData.amount,
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled,
            getSavePaymentMethod: makeGetSavePaymentMethod(inputData.savePaymentMethod),
            moneyAuthClientId: inputData.moneyAuthClientId,
            returnUrl: inputData.returnUrl,
            savePaymentMethod: inputData.savePaymentMethod
        )

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.presentPaymentMethods(
                inputData: paymentMethodsInputData,
                moduleOutput: self
            )
        }
    }

    func presentContract(paymentOption: PaymentOption) {
        let viewModel = makePaymentMethodViewModel(paymentOption: paymentOption)
        let tokenizeScheme = TokenizeSchemeFactory.makeTokenizeScheme(paymentOption)
        let savePaymentMethodViewModel = SavePaymentMethodViewModelFactory.makeSavePaymentMethodViewModel(
            paymentOption,
            inputData.savePaymentMethod,
            initialState: makeInitialSavePaymentMethod(inputData.savePaymentMethod)
        )
        let moduleInputData = ContractModuleInputData(
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            paymentMethod: viewModel,
            price: makePriceViewModel(paymentOption),
            fee: makeFeePriceViewModel(paymentOption),
            shouldChangePaymentMethod: shouldChangePaymentOptions,
            testModeSettings: inputData.testModeSettings,
            tokenizeScheme: tokenizeScheme,
            isLoggingEnabled: inputData.isLoggingEnabled,
            termsOfService: termsOfService,
            savePaymentMethodViewModel: savePaymentMethodViewModel
        )

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.presentContract(
                inputData: moduleInputData,
                moduleOutput: self
            )
        }
    }

    func presentBankCardDataInput() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let bankCardDataInputData = BankCardDataInputModuleInputData(
                cardScanner: self.inputData.cardScanning,
                testModeSettings: self.inputData.testModeSettings,
                isLoggingEnabled: self.inputData.isLoggingEnabled
            )
            self.router.presentBankCardDataInput(
                inputData: bankCardDataInputData,
                moduleOutput: self
            )
        }
    }

    func presentMaskedBankCardDataInput(
        paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    ) {
        let moduleInputData = MaskedBankCardDataInputModuleInputData(
            cardMask: paymentOption.cardMask,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled,
            analyticsEvent: .screenLinkedCardForm,
            tokenizeScheme: .linkedCard
        )
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.presenMaskedBankCardDataInput(
                inputData: moduleInputData,
                moduleOutput: self
            )
        }
    }

    func presentSberbankContract(paymentOption: PaymentOption) {
        let viewModel = makePaymentMethodViewModel(paymentOption: paymentOption)
        let priceViewModel = makePriceViewModel(paymentOption)
        let tokenizeScheme = TokenizeSchemeFactory.makeTokenizeScheme(paymentOption)
        let moduleInputData = SberbankModuleInputData(
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            paymentMethod: viewModel,
            price: priceViewModel,
            fee: makeFeePriceViewModel(paymentOption),
            shouldChangePaymentMethod: shouldChangePaymentOptions,
            testModeSettings: inputData.testModeSettings,
            tokenizeScheme: tokenizeScheme,
            isLoggingEnabled: inputData.isLoggingEnabled,
            phoneNumber: inputData.userPhoneNumber,
            termsOfService: termsOfService,
            savePaymentMethodViewModel: nil
        )
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.presentSberbank(
                inputData: moduleInputData,
                moduleOutput: self
            )
        }
    }

    func present3dsModule(
        inputData: CardSecModuleInputData
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.present3dsModule(
                inputData: inputData,
                moduleOutput: self
            )
        }
    }

    func tokenize(
        _ data: TokenizeData,
        paymentOption: PaymentOption
    ) {
        tokenizeData = data
        var tmxSessionId: String?
        if paymentOption is PaymentInstrumentYooMoneyWallet {
            tmxSessionId = self.tmxSessionId
        }
        interactor.tokenize(
            data,
            paymentOption: paymentOption,
            tmxSessionId: tmxSessionId
        )
    }

    func loginInWallet(
        reusableToken: Bool,
        paymentOption: PaymentOption
    ) {
        var tmxSessionId: String?
        if paymentOption is PaymentInstrumentYooMoneyWallet {
            tmxSessionId = self.tmxSessionId
        }
        interactor.loginInWallet(
            reusableToken: reusableToken,
            paymentOption: paymentOption,
            tmxSessionId: tmxSessionId
        )
    }

    func logout(accountId: String) {
        let walletDisplayName = interactor.getWalletDisplayName()
        let inputData = LogoutConfirmationModuleInputData(
            accountName: walletDisplayName ?? accountId
        )
        router.presentLogoutConfirmation(
            inputData: inputData,
            moduleOutput: self
        )
    }

    func presentApplePay(_ paymentOption: PaymentOption) {
        let moduleInputData = ApplePayModuleInputData(
            merchantIdentifier: inputData.applePayMerchantIdentifier,
            amount: MonetaryAmountFactory.makeAmount(paymentOption.charge),
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            supportedNetworks: ApplePayConstants.paymentNetworks,
            fee: paymentOption.fee?.plain
        )
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.presentApplePay(
                inputData: moduleInputData,
                moduleOutput: self
            )
        }
    }

    func presentApplePayContract(_ paymentOption: PaymentOption) {
        let viewModel = makePaymentMethodViewModel(paymentOption: paymentOption)
        let savePaymentMethodViewModel = SavePaymentMethodViewModelFactory.makeSavePaymentMethodViewModel(
            paymentOption,
            inputData.savePaymentMethod,
            initialState: makeInitialSavePaymentMethod(inputData.savePaymentMethod)
        )
        let moduleInputData = ApplePayContractModuleInputData(
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            paymentMethod: viewModel,
            price: makePriceViewModel(paymentOption),
            fee: makeFeePriceViewModel(paymentOption),
            shouldChangePaymentMethod: shouldChangePaymentOptions,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled,
            termsOfService: termsOfService,
            savePaymentMethodViewModel: savePaymentMethodViewModel
        )

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.presentApplePayContract(
                inputData: moduleInputData,
                moduleOutput: self
            )
        }
    }

    func presentErrorWithMessage(_ message: String) {
        let moduleInputData = ErrorModuleInputData(errorTitle: message)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.presentError(
                inputData: moduleInputData,
                moduleOutput: self
            )
        }
    }

    func didFinish(on module: TokenizationStrategyInput) {
        handleOnePaymentOptionMethodAtReturn()
    }

    func handleOnePaymentOptionMethodAtReturn() {
        if paymentOptionsCount == Constants.minimalRecommendedPaymentsOptions {
            close()
        } else {
            presentPaymentMethodsModule()
        }
    }

    func presentTermsOfServiceModule(_ url: URL) {
        router.presentTermsOfServiceModule(url)
    }

    func presentSavePaymentMethodInfoModule() {
        guard let paymentOption = paymentOption,
              let savePaymentMethodInfoValues = makeSavePaymentMethodInfoValues(
                paymentOption: paymentOption
              ) else { return }

        let savePaymentMethodModuleinputData = SavePaymentMethodInfoModuleInputData(
            headerValue: savePaymentMethodInfoValues.headerValue,
            bodyValue: savePaymentMethodInfoValues.bodyValue
        )
        router.presentSavePaymentMethodInfo(inputData: savePaymentMethodModuleinputData)
    }
}

// MARK: - TokenizationViewOutput

extension TokenizationPresenter: TokenizationViewOutput {
    func closeDidPress() {
        close()
    }

    func setupView() {
        view?.setCustomizationSettings()
        interactor.startAnalyticsService()
        presentPaymentMethodsModule()
    }
}

// MARK: - TokenizationInteractorOutput

extension TokenizationPresenter: TokenizationInteractorOutput {
    func didTokenizeData(_ token: Tokens) {
        guard let paymentOption = paymentOption,
              let tokenizeData = tokenizeData else { return }

        let event = makeAnalyticsEventFromTokenizeData(tokenizeData)
        interactor.trackEvent(event)
        interactor.stopAnalyticsService()

        strategy?.didTokenizeData()

        if strategy?.shouldInvalidateTokenizeData == true {
            strategy?.shouldInvalidateTokenizeData = false
        } else {
            moduleOutput?.tokenizationModule(
                self,
                didTokenize: token,
                paymentMethodType: paymentOption.paymentMethodType.plain
            )
        }
    }

    func failTokenizeData(_ error: Error) {
        strategy?.failTokenizeData(error)
    }

    func didLoginInWallet(_ response: WalletLoginResponse) {
        strategy?.didLoginInWallet(response)

        if case .authorized = response {
            DispatchQueue.global().async { [weak self] in
                guard let interactor = self?.interactor else { return }
                interactor.trackEvent(.actionPaymentAuthorization(.success))
            }
        }
    }

    func failLoginInWallet(_ error: Error) {
        strategy?.failLoginInWallet(error)

        DispatchQueue.global().async { [weak self] in
            guard let interactor = self?.interactor else { return }
            interactor.trackEvent(.actionPaymentAuthorization(.fail))
        }
    }

    private func makeAnalyticsEventFromTokenizeData(_ tokenizeData: TokenizeData) -> AnalyticsEvent {

        let scheme: AnalyticsEvent.TokenizeScheme
        let type = interactor.makeTypeAnalyticsParameters()

        switch tokenizeData {
        case .bankCard:
            scheme = .bankCard
        case .wallet:
            scheme = .wallet
        case .linkedBankCard:
            scheme = .linkedCard
        case .applePay:
            scheme = .applePay
        case .sberbank:
            scheme = .smsSbol
        }

        let event: AnalyticsEvent = .actionTokenize(
            scheme: scheme,
            authType: type.authType,
            tokenType: type.tokenType
        )
        return event
    }
}

// MARK: - TokenizationModuleInput

extension TokenizationPresenter: TokenizationModuleInput {
    func start3dsProcess(requestUrl: String) {
        let moduleInputData = CardSecModuleInputData(
            requestUrl: requestUrl,
            redirectUrl: inputData.returnUrl ?? Constants.returnUrl,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        present3dsModule(inputData: moduleInputData)
    }
}

// MARK: - PaymentMethodsModuleOutput

extension TokenizationPresenter: PaymentMethodsModuleOutput {
    func paymentMethodsModule(
        _ module: PaymentMethodsModuleInput,
        didSelect paymentOption: PaymentOption,
        methodsCount: Int
    ) {
        paymentOptionsCount = methodsCount

        if paymentOption is PaymentInstrumentYooMoneyWallet
        || paymentOption is PaymentInstrumentYooMoneyLinkedBankCard
        || paymentOption.paymentMethodType == .bankCard
        || paymentOption.paymentMethodType == .sberbank
        || paymentOption.paymentMethodType == .applePay {
            self.paymentOption = paymentOption
            strategy?.beginProcess()
        }
    }

    func paymentMethodsModule(
        _ module: PaymentMethodsModuleInput,
        didPressLogout paymentOption: PaymentInstrumentYooMoneyWallet
    ) {
        logout(accountId: paymentOption.accountId)
        self.paymentOption = nil
    }

    func didFinish(on module: PaymentMethodsModuleInput) {
        close()
    }
    
    func tokenizationModule(
        _ module: PaymentMethodsModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    ) {
        let scheme: AnalyticsEvent.TokenizeScheme
        let type = interactor.makeTypeAnalyticsParameters()
        let event: AnalyticsEvent = .actionTokenize(
            scheme: .wallet,
            authType: type.authType,
            tokenType: type.tokenType
        )
        interactor.trackEvent(event)
        interactor.stopAnalyticsService()
        
        moduleOutput?.tokenizationModule(
            self,
            didTokenize: token,
            paymentMethodType: paymentMethodType
        )
    }
}

// MARK: - ContractModuleOutput

extension TokenizationPresenter: ContractModuleOutput {
    func didPressSubmitButton(on module: ContractModuleInput) {
        strategy?.didPressSubmitButton(
            on: module
        )
    }

    func didPressChangeAction(on module: ContractModuleInput) {
        interactor.trackEvent(.actionChangePaymentMethod)
        presentPaymentMethodsModule()
    }

    func didFinish(on module: ContractModuleInput) {
        close()
    }

    func didPressLogoutButton(on module: ContractModuleInput) {
        strategy?.didPressLogout()
    }

    func contractModule(
        _ module: ContractModuleInput,
        didTapTermsOfService url: URL
    ) {
        presentTermsOfServiceModule(url)
    }

    func contractModule(
        _ module: ContractModuleInput,
        didChangeSavePaymentMethodState state: Bool
    ) {
        strategy?.savePaymentMethod = state
    }

    func didTapOnSavePaymentMethodInfo(
        on module: ContractModuleInput
    ) {
        presentSavePaymentMethodInfoModule()
    }
}

// MARK: - SberbankModuleOutput

extension TokenizationPresenter: SberbankModuleOutput {
    func sberbank(
        _ module: SberbankModuleInput,
        phoneNumber: String
    ) {
        strategy?.sberbankModule(module, didPressConfirmButton: phoneNumber)
    }

    func didFinish(on module: SberbankModuleInput) {
        close()
    }

    func didPressChangeAction(on module: SberbankModuleInput) {
        interactor.trackEvent(.actionChangePaymentMethod)
        presentPaymentMethodsModule()
    }

    func sberbank(
        _ module: SberbankModuleInput,
        didTapTermsOfService url: URL
    ) {
        presentTermsOfServiceModule(url)
    }
}

// MARK: - BankCardDataInputModuleOutput

extension TokenizationPresenter: BankCardDataInputModuleOutput {
    func bankCardDataInputModule(
        _ module: BankCardDataInputModuleInput,
        didPressConfirmButton bankCardData: CardData
    ) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let strategy = self.strategy else { return }
            strategy.bankCardDataInputModule(
                module,
                didPressConfirmButton: bankCardData
            )
        }
    }

    func didPressCloseBarButtonItem(on module: BankCardDataInputModuleInput) {
        if paymentOptionsCount > Constants.minimalRecommendedPaymentsOptions {
            strategy?.shouldInvalidateTokenizeData = true
            presentPaymentMethodsModule()
        } else {
            close()
        }
    }
}

// MARK: - MaskedBankCardDataInputModuleOutput

extension TokenizationPresenter: MaskedBankCardDataInputModuleOutput {
    func didPressConfirmButton(
        on module: BankCardDataInputModuleInput,
        cvc: String
    ) {
        DispatchQueue.global().async { [weak self] in
            guard let strategy = self?.strategy else { return }
            strategy.didPressConfirmButton(on: module, cvc: cvc)
        }
    }
}

// MARK: - LogoutConfirmationModuleOutput

extension TokenizationPresenter: LogoutConfirmationModuleOutput {
    func logoutDidConfirm(on module: LogoutConfirmationModuleInput) {
        DispatchQueue.global().async { [weak self] in
            guard let interactor = self?.interactor else { return }
            interactor.logout()
            interactor.trackEvent(.actionLogout)

            DispatchQueue.main.async {
                guard let self = self else { return }
                self.paymentOption = nil
                self.strategy = nil
                self.presentPaymentMethodsModule()
            }
        }
    }

    func logoutDidCancel(on module: LogoutConfirmationModuleInput) {}
}

// MARK: - CardSecModuleOutput

extension TokenizationPresenter: CardSecModuleOutput {
    func didSuccessfullyPassedCardSec(on module: CardSecModuleInput) {
        moduleOutput?.didSuccessfullyPassedCardSec(on: self)
    }

    func didPressCloseButton(on module: CardSecModuleInput) {
        close()
    }
}

// MARK: - ApplePayModuleOutput

extension TokenizationPresenter: ApplePayModuleOutput {
    func didPresentApplePayModule() {
        strategy?.didPresentApplePayModule()
    }

    func didFailPresentApplePayModule() {
        strategy?.didFailPresentApplePayModule()
    }

    @available(iOS 11.0, *)
    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        paymentAuthorizationViewController(
            controller,
            didAuthorizePayment: payment
        ) { status in
            completion(PKPaymentAuthorizationResult(status: status, errors: nil))
        }
    }

    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        completion: @escaping (PKPaymentAuthorizationStatus) -> Void
    ) {
        strategy?.paymentAuthorizationViewController(
            controller,
            didAuthorizePayment: payment,
            completion: completion
        )
    }

    func paymentAuthorizationViewControllerDidFinish(
        _ controller: PKPaymentAuthorizationViewController
    ) {
        strategy?.paymentAuthorizationViewControllerDidFinish(controller)
    }
}

// MARK: - ApplePayContractModuleOutput

extension TokenizationPresenter: ApplePayContractModuleOutput {
    func didFinish(on module: ApplePayContractModuleInput) {
        close()
    }

    func didPressChangeAction(on module: ApplePayContractModuleInput) {
        DispatchQueue.global().async { [weak self] in
            guard let interactor = self?.interactor else { return }
            interactor.trackEvent(.actionChangePaymentMethod)
        }

        presentPaymentMethodsModule()
    }

    func didPressSubmitButton(on module: ApplePayContractModuleInput) {
         strategy?.didPressSubmitButton(on: module)
    }

    func applePayContractModule(
        _ module: ApplePayContractModuleInput,
        didTapTermsOfService url: URL
    ) {
        presentTermsOfServiceModule(url)
    }

    func applePayContractModule(
        _ module: ApplePayContractModuleInput,
        didChangeSavePaymentMethodState state: Bool
    ) {
        strategy?.savePaymentMethod = state
    }

    func didTapOnSavePaymentMethodInfo(
        on module: ApplePayContractModuleInput
    ) {
        presentSavePaymentMethodInfoModule()
    }
}

// MARK: - ErrorModuleOutput

extension TokenizationPresenter: ErrorModuleOutput {
    func didPressPlaceholderButton(on module: ErrorModuleInput) {
        presentPaymentMethodsModule()
    }
}

// MARK: - Module helpers

private extension TokenizationPresenter {
    func close() {
        interactor?.stopAnalyticsService()
        moduleOutput?.didFinish(on: self, with: nil)
    }
}

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

private func makeStrategy(
    paymentOption: PaymentOption,
    output: TokenizationStrategyOutput?,
    testModeSettings: TestModeSettings?,
    returnUrl: String,
    isLoggingEnabled: Bool,
    savePaymentMethod: SavePaymentMethod,
    moneyAuthClientId: String?
) -> TokenizationStrategyInput {
    let authorizationService = AuthorizationServiceAssembly.makeService(
        isLoggingEnabled: isLoggingEnabled,
        testModeSettings: testModeSettings,
        moneyAuthClientId: moneyAuthClientId
    )

    let analyticsService = AnalyticsServiceAssembly.makeService(
        isLoggingEnabled: isLoggingEnabled
    )
    let analyticsProvider = AnalyticsProviderAssembly.makeProvider(
        testModeSettings: testModeSettings
    )

    let strategy: TokenizationStrategyInput
    if let bankCard = try? BankCardStrategy(
        paymentOption: paymentOption,
        returnUrl: returnUrl,
        savePaymentMethod: makeInitialSavePaymentMethod(savePaymentMethod)
    ) {
        strategy = bankCard
    } else if let linkedBankCard = try? LinkedBankCardStrategy(
        authorizationService: authorizationService,
        paymentOption: paymentOption,
        returnUrl: returnUrl,
        savePaymentMethod: makeInitialSavePaymentMethod(savePaymentMethod)
    ) {
        strategy = linkedBankCard
    } else if let sberbankStrategy = try? SberbankStrategy(
        paymentOption: paymentOption,
        savePaymentMethod: false
    ) {
        strategy = sberbankStrategy
    } else if let applePay = try? ApplePayStrategy(
        paymentOption: paymentOption,
        analyticsService: analyticsService,
        analyticsProvider: analyticsProvider,
        savePaymentMethod: makeInitialSavePaymentMethod(savePaymentMethod),
        inputSavePaymentMethod: savePaymentMethod
    ) {
        strategy = applePay
    } else {
        fatalError("Unsupported strategy")
    }

    strategy.output = output
    return strategy
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

private func makeGetSavePaymentMethod(
    _ savePaymentMethod: SavePaymentMethod
) -> Bool? {
    let getSavePaymentMethod: Bool?

    switch savePaymentMethod {
    case .on:
        getSavePaymentMethod = true

    case .off:
        getSavePaymentMethod = false

    case .userSelects:
        getSavePaymentMethod = nil
    }

    return getSavePaymentMethod
}

private func makeSavePaymentMethodInfoValues(
    paymentOption: PaymentOption
) -> (headerValue: String, bodyValue: String)? {
    let headerValue: String
    let bodyValue: String

    if paymentOption is PaymentInstrumentYooMoneyWallet {
        headerValue = §SavePaymentMethodInfoLocalization.Wallet.header
        bodyValue = §SavePaymentMethodInfoLocalization.Wallet.body
    } else if paymentOption.paymentMethodType == .bankCard
        || paymentOption is PaymentInstrumentYooMoneyLinkedBankCard
        || paymentOption.paymentMethodType == .applePay {
        headerValue = §SavePaymentMethodInfoLocalization.BankCard.header
        bodyValue = §SavePaymentMethodInfoLocalization.BankCard.body
    } else {
        assertionFailure("Unsupported paymentMethod to present savePaymentMethod info")
        return nil
    }
    return (headerValue, bodyValue)
}

// MARK: - Constants

private enum Constants {
    static let returnUrl = "https://custom.redirect.url/"
    static let minimalRecommendedPaymentsOptions = 1
}
