import class When.Promise
import enum YandexCheckoutWalletApi.AuthType
import struct YandexCheckoutWalletApi.AuthTypeState
import struct YandexCheckoutWalletApi.MonetaryAmount

enum AuthorizationProcessingError: Error {
    case passportNotAuthorized
}

protocol AuthorizationProcessing {
    func getYandexToken() -> String?
    func getYamoneyToken() -> String?
    func getYandexDisplayName() -> String?
    func hasReusableYamoneyToken() -> Bool
    func loginInYandex() -> Promise<String>
    func loginInYamoney(merchantClientAuthorization: String,
                        amount: MonetaryAmount,
                        reusableToken: Bool) -> Promise<YamoneyLoginResponse>
    func startNewAuthSession(merchantClientAuthorization: String,
                             contextId: String,
                             authType: AuthType) -> Promise<AuthTypeState>
    func checkUserAnswer(merchantClientAuthorization: String,
                         authContextId: String,
                         authType: AuthType,
                         answer: String,
                         processId: String) -> Promise<YamoneyLoginResponse>
    func logout()
}
