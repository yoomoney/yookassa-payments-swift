import PassKit
import YandexCheckoutPaymentsApi

final class SberbankStrategy {

    let paymentOption: PaymentOption

    weak var output: TokenizationStrategyOutput?
    weak var contractStateHandler: ContractStateHandler?

    init(paymentOption: PaymentOption) throws {
        guard case .sberbank = paymentOption.paymentMethodType else {
            throw TokenizationStrategyError.incorrectPaymentOptions
        }

        self.paymentOption = paymentOption
    }
}

extension SberbankStrategy: TokenizationStrategyInput {
    func beginProcess() {
        output?.presentSberbankContract(paymentOption: paymentOption)
    }

    func didPressSubmitButton(on module: ContractModuleInput) { }

    func didLoginInYandexMoney(_ response: YamoneyLoginResponse) { }

    func yamoneyAuthParameters(_ module: YamoneyAuthParametersModuleInput,
                               loginWithReusableToken isReusableToken: Bool) { }

    func sberbankModule(_ module: SberbankModuleInput, didPressConfirmButton phoneNumber: String) {
        contractStateHandler = module
        let tokenizeData = TokenizeData.sberbank(phoneNumber: phoneNumber)
        module.showActivity()
        output?.tokenize(tokenizeData)
    }

    func failTokenizeData(_ error: Error) {
        contractStateHandler?.failTokenizeData(error)
    }

    func failLoginInYandexMoney(_ error: Error) { }

    func failResendSmsCode(_ error: Error) { }

    func bankCardDataInputModule(_ module: BankCardDataInputModuleInput,
                                 didPressConfirmButton bankCardData: CardData) { }

    func didPressConfirmButton(on module: BankCardDataInputModuleInput, cvc: String) { }

    func didPressLogout() { }

    func paymentAuthorizationViewController(_ controller: PassKit.PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PassKit.PKPayment,
                                            completion: @escaping (PassKit.PKPaymentAuthorizationStatus) -> Void) {

    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PassKit.PKPaymentAuthorizationViewController) {
    }

    func didPresentApplePayModule() {
    }

    func didFailPresentApplePayModule() {
    }
}
