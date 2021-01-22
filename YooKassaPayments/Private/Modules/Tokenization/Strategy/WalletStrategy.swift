import PassKit
import YooKassaPaymentsApi

final class WalletStrategy {

    // MARK: - Outputs

    weak var output: TokenizationStrategyOutput?
    weak var contractStateHandler: ContractStateHandler?

    // MARK: - Init data

    var savePaymentMethod: Bool

    private let authorizationService: AuthorizationService
    private let paymentOption: PaymentInstrumentYooMoneyWallet
    private let returnUrl: String

    // MARK: - Init

    init(
        authorizationService: AuthorizationService,
        paymentOption: PaymentOption,
        returnUrl: String,
        savePaymentMethod: Bool
    ) throws {
        guard let paymentOption = paymentOption as? PaymentInstrumentYooMoneyWallet else {
            throw TokenizationStrategyError.incorrectPaymentOptions
        }
        self.paymentOption = paymentOption
        self.authorizationService = authorizationService
        self.returnUrl = returnUrl
        self.savePaymentMethod = savePaymentMethod
    }

    // MARK: - Properties

    var shouldInvalidateTokenizeData = false
}

// MARK: - TokenizationStrategyInput

extension WalletStrategy: TokenizationStrategyInput {
    func beginProcess() {
        if authorizationService.hasReusableWalletToken() {
            output?.presentContract(paymentOption: paymentOption)
        } else {
            output?.presentWalletAuthParametersModule(paymentOption: paymentOption)
        }
    }

    func didPressSubmitButton(
        on module: ContractModuleInput
    ) {
        contractStateHandler = module
        module.hidePlaceholder()
        module.showActivity()

        let tokenizeData: TokenizeData = .wallet(
            confirmation: makeConfirmation(returnUrl: returnUrl),
            savePaymentMethod: savePaymentMethod
        )
        output?.tokenize(tokenizeData, paymentOption: paymentOption)
    }

    func walletAuthParameters(
        _ module: WalletAuthParametersModuleInput,
        loginWithReusableToken isReusableToken: Bool
    ) {
        contractStateHandler = module
        module.hidePlaceholder()
        module.showActivity()

        output?.loginInWallet(
            reusableToken: isReusableToken,
            paymentOption: paymentOption
        )
    }

    func didLoginInWallet(
        _ response: WalletLoginResponse
    ) {
        switch response {
        case .authorized:
            let tokenizeData: TokenizeData = .wallet(
                confirmation: makeConfirmation(returnUrl: returnUrl),
                savePaymentMethod: savePaymentMethod
            )
            output?.tokenize(tokenizeData, paymentOption: paymentOption)
        case let .notAuthorized(authTypeState: authTypeState, processId: processId, authContextId: authContextId):
            output?.presentWalletAuthModule(
                paymentOption: paymentOption,
                processId: processId,
                authContextId: authContextId,
                authTypeState: authTypeState
            )
        }
    }

    func failLoginInWallet(_ error: Error) {
        contractStateHandler?.didFailLoginInWallet(error)
    }

    func failTokenizeData(_ error: Error) {
        contractStateHandler?.failTokenizeData(error)
    }

    func failResendSmsCode(_ error: Error) {
        contractStateHandler?.failResendSmsCode(error)
    }

    func didPressLogout() {
        output?.logout(accountId: paymentOption.accountId)
    }

    func bankCardDataInputModule(
        _ module: BankCardDataInputModuleInput,
        didPressConfirmButton bankCardData: CardData
    ) {}
    func sberbankModule(
        _ module: SberbankModuleInput,
        didPressConfirmButton phoneNumber: String
    ) {}
    func didPressConfirmButton(
        on module: BankCardDataInputModuleInput,
        cvc: String
    ) {}
    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        completion: @escaping (PKPaymentAuthorizationStatus) -> Void
    ) {}
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {}
    func didFailPresentApplePayModule() {}
    func didPresentApplePayModule() {}
    func didPressSubmitButton(on module: ApplePayContractModuleInput) {}
    func didTokenizeData() {}
}

private func makeConfirmation(returnUrl: String) -> Confirmation {
    return Confirmation(type: .redirect, returnUrl: returnUrl)
}
