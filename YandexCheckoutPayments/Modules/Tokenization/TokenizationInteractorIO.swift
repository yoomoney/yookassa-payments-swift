import YandexCheckoutPaymentsApi
import enum YandexCheckoutWalletApi.AuthType
import struct YandexCheckoutWalletApi.AuthTypeState

enum TokenizeData {
    case bankCard(BankCard)
    case wallet
    case linkedBankCard(id: String, csc: String)
    case applePay(paymentData: String)
    case sberbank(phoneNumber: String)
}

protocol TokenizationInteractorInput: AnalyticsTrackable, AnalyticsProviding {
    func tokenize(_ data: TokenizeData)

    func isAuthorizedInYandex() -> Bool
    func getYandexDisplayName() -> String?

    func loginInYandexMoney(reusableToken: Bool)
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
