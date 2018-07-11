import FunctionalSwift
import YandexCheckoutPaymentsApi
import struct YandexCheckoutWalletApi.AuthTypeState
import PassKit

final class LinkedBankCardStrategy {
    let authorizationService: AuthorizationProcessing
    let paymentOption: PaymentInstrumentYandexMoneyLinkedBankCard

    weak var output: TokenizationStrategyOutput?
    weak var contractStateHandler: ContractStateHandler?
    fileprivate weak var bankCardDataInputModule: BankCardDataInputModuleInput?

    init(authorizationService: AuthorizationProcessing,
         paymentOption: PaymentOption) throws {
        guard let paymentOption = paymentOption as? PaymentInstrumentYandexMoneyLinkedBankCard else {
            throw TokenizationStrategyError.incorrectPaymentOptions
        }
        self.paymentOption = paymentOption
        self.authorizationService = authorizationService
    }
}

extension LinkedBankCardStrategy: TokenizationStrategyInput {

    func beginProcess() {
        if authorizationService.hasReusableYamoneyToken() {
            output?.presentContract(paymentOption: paymentOption)
        } else {
            output?.presentYamoneyAuthParametersModule(paymentOption: paymentOption)
        }
    }

    func didPressSubmitButton(on module: ContractModuleInput) {
        output?.presentLinkedBankCardDataInput(paymentOption: paymentOption)
    }

    func yamoneyAuthParameters(_ module: YamoneyAuthParametersModuleInput,
                               loginWithReusableToken isReusableToken: Bool) {

        contractStateHandler = module
        module.hidePlaceholder()
        module.showActivity()

        output?.loginInYandexMoney(reusableToken: isReusableToken)
    }

    func didLoginInYandexMoney(_ response: YamoneyLoginResponse) {
        switch response {
        case .authorized:
            output?.presentLinkedBankCardDataInput(paymentOption: paymentOption)
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

    func bankCardDataInputModule(_ module: BankCardDataInputModuleInput,
                                 didPressConfirmButton bankCardData: CardData) {}

    func didPressConfirmButton(on module: BankCardDataInputModuleInput, cvc: String) {
        bankCardDataInputModule = module
        output?.tokenize(.linkedBankCard(id: paymentOption.cardId, csc: cvc))
    }

    func didPressLogout() { }

    func sberbankModule(_ module: SberbankModuleInput, didPressConfirmButton phoneNumber: String) { }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            completion: @escaping (PKPaymentAuthorizationStatus) -> Void) { }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) { }

    func didFailPresentApplePayModule() { }

    func didPresentApplePayModule() { }
}
