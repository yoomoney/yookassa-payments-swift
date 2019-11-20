import YandexCheckoutPaymentsApi
import enum YandexCheckoutWalletApi.AuthType
import struct YandexCheckoutWalletApi.AuthTypeState

enum TokenizeData {
    case bankCard(bankCard: BankCard, confirmation: Confirmation, savePaymentMethod: Bool)
    case wallet(confirmation: Confirmation, savePaymentMethod: Bool)
    case linkedBankCard(id: String, csc: String, confirmation: Confirmation, savePaymentMethod: Bool)
    case applePay(paymentData: String, savePaymentMethod: Bool)
    case sberbank(phoneNumber: String, confirmation: Confirmation, savePaymentMethod: Bool)
}

protocol TokenizationInteractorInput: AnalyticsTrackable, AnalyticsProviding {
    func tokenize(_ data: TokenizeData, paymentOption: PaymentOption)

    func isAuthorizedInYandex() -> Bool
    func getYandexDisplayName() -> String?

    func loginInYandexMoney(reusableToken: Bool, paymentOption: PaymentOption)
    func resendSmsCode(authContextId: String, authType: AuthType)
    func loginInYandexMoney(authContextId: String,
                            authType: AuthType,
                            answer: String,
                            processId: String)

    func logout()
    func startAnalyticsService()
    func stopAnalyticsService()
}

protocol TokenizationInteractorOutput: class {
    func didTokenizeData(_ token: Tokens)
    func failTokenizeData(_ error: Error)

    func didLoginInYandexMoney(_ response: YamoneyLoginResponse)
    func failLoginInYandexMoney(_ error: Error)

    func didResendSmsCode(_ authTypeState: AuthTypeState)
    func failResendSmsCode(_ error: Error)
}
