import FunctionalSwift
import YandexCheckoutPaymentsApi
import struct YandexCheckoutWalletApi.AuthTypeState
import PassKit

final class LinkedBankCardStrategy {

    weak var output: TokenizationStrategyOutput?
    weak var contractStateHandler: ContractStateHandler?

    private weak var bankCardDataInputModule: BankCardDataInputModuleInput?

    var savePaymentMethod: Bool
    var shouldInvalidateTokenizeData = false

    private let authorizationService: AuthorizationProcessing
    private let paymentOption: PaymentInstrumentYandexMoneyLinkedBankCard
    private let returnUrl: String

    init(
        authorizationService: AuthorizationProcessing,
        paymentOption: PaymentOption,
        returnUrl: String,
        savePaymentMethod: Bool
    ) throws {
        guard let paymentOption = paymentOption as? PaymentInstrumentYandexMoneyLinkedBankCard else {
            throw TokenizationStrategyError.incorrectPaymentOptions
        }
        self.paymentOption = paymentOption
        self.authorizationService = authorizationService
        self.returnUrl = returnUrl
        self.savePaymentMethod = savePaymentMethod
    }
}

extension LinkedBankCardStrategy: TokenizationStrategyInput {
    func beginProcess() {
        if authorizationService.hasReusableWalletToken() {
            output?.presentContract(paymentOption: paymentOption)
        } else {
            output?.presentYamoneyAuthParametersModule(paymentOption: paymentOption)
        }
    }

    func didPressSubmitButton(on module: ContractModuleInput) {
        output?.presentMaskedBankCardDataInput(paymentOption: paymentOption)
    }

    func yamoneyAuthParameters(_ module: YamoneyAuthParametersModuleInput,
                               loginWithReusableToken isReusableToken: Bool) {

        contractStateHandler = module
        module.hidePlaceholder()
        module.showActivity()

        output?.loginInYandexMoney(reusableToken: isReusableToken, paymentOption: paymentOption)
    }

    func didLoginInYandexMoney(
        _ response: YamoneyLoginResponse
    ) {
        switch response {
        case .authorized:
            output?.presentMaskedBankCardDataInput(paymentOption: paymentOption)
        case let .notAuthorized(authTypeState: authTypeState, processId: processId, authContextId: authContextId):
            output?.presentYamoneyAuthModule(paymentOption: paymentOption,
                                             processId: processId,
                                             authContextId: authContextId,
                                             authTypeState: authTypeState)
        }
    }

    func failLoginInYandexMoney(_ error: Error) {
        contractStateHandler?.failLoginInYandexMoney(error)
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
    func sberbankModule(_ module: SberbankModuleInput, didPressConfirmButton phoneNumber: String) {}
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {}
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
