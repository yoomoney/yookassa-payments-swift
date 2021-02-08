import PassKit
import YooKassaPaymentsApi

final class LinkedBankCardStrategy {

    // MARK: - Outputs

    weak var output: TokenizationStrategyOutput?
    weak var contractStateHandler: ContractStateHandler?

    private weak var bankCardDataInputModule: BankCardDataInputModuleInput?

    // MARK: - Init data

    var savePaymentMethod: Bool

    private let authorizationService: AuthorizationService
    private let paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    private let returnUrl: String

    // MARK: - Init

    init(
        authorizationService: AuthorizationService,
        paymentOption: PaymentOption,
        returnUrl: String,
        savePaymentMethod: Bool
    ) throws {
        guard let paymentOption = paymentOption as? PaymentInstrumentYooMoneyLinkedBankCard else {
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

extension LinkedBankCardStrategy: TokenizationStrategyInput {
    func beginProcess() {
        if authorizationService.hasReusableWalletToken() {
            output?.presentContract(paymentOption: paymentOption)
        } else {
            // TODO: - Present wallet auth parameters
//            output?.presentWalletAuthParametersModule(paymentOption: paymentOption)
        }
    }

    func didPressSubmitButton(on module: ContractModuleInput) {
        output?.presentMaskedBankCardDataInput(paymentOption: paymentOption)
    }

    func didLoginInWallet(
        _ response: WalletLoginResponse
    ) {
        switch response {
        case .authorized:
            output?.presentMaskedBankCardDataInput(paymentOption: paymentOption)
        case let .notAuthorized(authTypeState: authTypeState, processId: processId, authContextId: authContextId):
            break
            // TODO: - https://jira.yamoney.ru/browse/MOC-1647
//            output?.presentWalletAuthModule(
//                paymentOption: paymentOption,
//                processId: processId,
//                authContextId: authContextId,
//                authTypeState: authTypeState
//            )
        }
    }

    func failLoginInWallet(_ error: Error) {
        contractStateHandler?.didFailLoginInWallet(error)
    }

    func failTokenizeData(_ error: Error) {
        bankCardDataInputModule?.bankCardDidTokenize(error)
    }

    func failResendSmsCode(_ error: Error) {
        contractStateHandler?.failResendSmsCode(error)
    }

    func didPressConfirmButton(
        on module: BankCardDataInputModuleInput,
        cvc: String
    ) {
        bankCardDataInputModule = module
        let confirmation = makeConfirmation(returnUrl: returnUrl)
        let tokenizeData: TokenizeData = .linkedBankCard(
            id: paymentOption.cardId,
            csc: cvc,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod
        )
        output?.tokenize(tokenizeData, paymentOption: paymentOption)
    }

    func didPressLogout() {}
    func sberbankModule(
        _ module: SberbankModuleInput,
        didPressConfirmButton phoneNumber: String
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
    func bankCardDataInputModule(
        _ module: BankCardDataInputModuleInput,
        didPressConfirmButton bankCardData: CardData
    ) {}
    func didTokenizeData() {}
}

private func makeConfirmation(returnUrl: String) -> Confirmation {
    return Confirmation(type: .redirect, returnUrl: returnUrl)
}
