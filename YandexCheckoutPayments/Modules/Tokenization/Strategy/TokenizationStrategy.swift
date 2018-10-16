import YandexCheckoutPaymentsApi
import struct YandexCheckoutWalletApi.AuthTypeState
import PassKit

enum TokenizationStrategyError: Error {
    case incorrectPaymentOptions
}

protocol TokenizationStrategyInput: class {

    var output: TokenizationStrategyOutput? { get set }
    var contractStateHandler: ContractStateHandler? { get set }

    func beginProcess()
    func didPressSubmitButton(on module: ContractModuleInput)
    func didLoginInYandexMoney(_ response: YamoneyLoginResponse)
    func yamoneyAuthParameters(_ module: YamoneyAuthParametersModuleInput,
                               loginWithReusableToken isReusableToken: Bool)

    func failTokenizeData(_ error: Error)
    func failLoginInYandexMoney(_ error: Error)
    func failResendSmsCode(_ error: Error)

    // MARK: - Sberbank

    func sberbankModule(_ module: SberbankModuleInput, didPressConfirmButton phoneNumber: String)

    // MARK: - Bank card inputs

    func bankCardDataInputModule(_ module: BankCardDataInputModuleInput,
                                 didPressConfirmButton bankCardData: CardData)

    func didPressConfirmButton(on module: BankCardDataInputModuleInput,
                               cvc: String)

    func didPressLogout()

    // MARK: - ApplePay

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            completion: @escaping (PKPaymentAuthorizationStatus) -> Void)

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController)

    func didPresentApplePayModule()

    func didFailPresentApplePayModule()
}

protocol TokenizationStrategyOutput: class {

    func presentPaymentMethodsModule()

    func presentYamoneyAuthParametersModule(paymentOption: PaymentOption)

    func presentYamoneyAuthModule(paymentOption: PaymentOption,
                                  processId: String,
                                  authContextId: String,
                                  authTypeState: AuthTypeState)

    func presentContract(paymentOption: PaymentOption)

    func presentBankCardDataInput()

    func presentLinkedBankCardDataInput(paymentOption: PaymentInstrumentYandexMoneyLinkedBankCard)

    func presentSberbankContract(paymentOption: PaymentOption)

    func tokenize(_ data: TokenizeData)

    func loginInYandexMoney(reusableToken: Bool)

    func logout(accountId: String)

    func presentErrorWithMessage(_ message: String)

    func didFinish(on module: TokenizationStrategyInput)

    // MARK: - ApplePay

    func presentApplePay()
}
