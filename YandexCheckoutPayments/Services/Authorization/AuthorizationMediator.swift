import class When.Promise
import FunctionalSwift
import YandexCheckoutWalletApi

final class AuthorizationMediator: AuthorizationProcessing {

    let tokenStorage: KeyValueStoring
    let yandexLoginService: YandexLoginProcessing
    let yamoneyLoginService: YamoneyLoginProcessing
    let deviceInfoService: DeviceInfoProvider
    let settingsStorage: KeyValueStoring

    init(tokenStorage: KeyValueStoring,
         yandexLoginService: YandexLoginProcessing,
         yamoneyLoginService: YamoneyLoginProcessing,
         deviceInfoService: DeviceInfoProvider,
         settingsStorage: KeyValueStoring) {
        self.tokenStorage = tokenStorage
        self.yandexLoginService = yandexLoginService
        self.yamoneyLoginService = yamoneyLoginService
        self.deviceInfoService = deviceInfoService
        self.settingsStorage = settingsStorage
    }

    func getYandexToken() -> String? {
        let token = tokenStorage.getString(for: Constants.Keys.yandexToken)
        return transformTokenIfNeeded(settingsStorage: settingsStorage) <^> token
    }

    func getYamoneyToken() -> String? {
        return tokenStorage.getString(for: Constants.Keys.yamoneyToken)
    }

    func getYandexDisplayName() -> String? {
        return tokenStorage.getString(for: Constants.Keys.yandexDisplayName)
    }

    func hasReusableYamoneyToken() -> Bool {
        return getYamoneyToken() != nil && tokenStorage.getBool(for: Constants.Keys.isReusableYamoneyToken) == true
    }

    func loginInYandex() -> Promise<String> {
        yandexLoginService.logout()
        let yandexLoginResponse = yandexLoginService.authorize()
        let savedResponse = saveYandexLoginResponseInStorage <^> yandexLoginResponse
        let savedToken = makeYandexLoginToken <^> savedResponse
        return transformTokenIfNeeded(settingsStorage: settingsStorage) <^> savedToken
    }

    func loginInYamoney(merchantClientAuthorization: String,
                        amount: MonetaryAmount,
                        reusableToken: Bool) -> Promise<YamoneyLoginResponse> {

        if let token = getYamoneyToken(), hasReusableYamoneyToken() {
            return Promise { return YamoneyLoginResponse.authorized(CheckoutTokenIssueExecute(accessToken: token)) }
        }

        guard let passportAuthorization = getYandexToken() else {
            return Promise { throw AuthorizationProcessingError.passportNotAuthorized }
        }

        tokenStorage.set(string: nil, for: Constants.Keys.yamoneyToken)
        tokenStorage.set(bool: reusableToken, for: Constants.Keys.isReusableYamoneyToken)

        let instanceName = deviceInfoService.getDeviceName()
        let amount = reusableToken ? nil : amount

        let request = curry(yamoneyLoginService.requestAuthorization)
        let authorizedRequest = request(passportAuthorization)(merchantClientAuthorization)(instanceName)
        let paymentUsageLimit: PaymentUsageLimit = reusableToken ? .multiple : .single

        let tmxSessionId = ThreatMetrixService.profileApp()

        let response = authorizedRequest(amount)(paymentUsageLimit) -<< tmxSessionId
        return saveYamoneyLoginInStorage <^> response
    }

    func startNewAuthSession(merchantClientAuthorization: String,
                             contextId: String,
                             authType: AuthType) -> Promise<AuthTypeState> {
        guard let passportAuthorization = getYandexToken() else {
            return Promise { throw  AuthorizationProcessingError.passportNotAuthorized }
        }

        return yamoneyLoginService.startNewSession(passportAuthorization: passportAuthorization,
                                                   merchantClientAuthorization: merchantClientAuthorization,
                                                   authContextId: contextId,
                                                   authType: authType)
    }

    func checkUserAnswer(merchantClientAuthorization: String,
                         authContextId: String,
                         authType: AuthType,
                         answer: String,
                         processId: String) -> Promise<YamoneyLoginResponse> {
        guard let passportAuthorization = getYandexToken() else {
            return Promise { throw  AuthorizationProcessingError.passportNotAuthorized }
        }

        let token = yamoneyLoginService.checkUserAnswer(passportAuthorization: passportAuthorization,
                                                        merchantClientAuthorization: merchantClientAuthorization,
                                                        authContextId: authContextId,
                                                        authType: authType,
                                                        answer: answer,
                                                        processId: processId)
        let response = makeYamoneyLoginResponse <^> token
        return saveYamoneyLoginInStorage <^> response
    }

    func logout() {
        tokenStorage.set(string: nil, for: Constants.Keys.yandexToken)
        tokenStorage.set(string: nil, for: Constants.Keys.yamoneyToken)
        tokenStorage.set(string: nil, for: Constants.Keys.yandexDisplayName)
        yandexLoginService.logout()
    }

    func saveYandexLoginResponseInStorage(_ response: YandexLoginResponse) -> YandexLoginResponse {
        tokenStorage.set(string: response.token, for: Constants.Keys.yandexToken)
        tokenStorage.set(string: response.displayName, for: Constants.Keys.yandexDisplayName)
        return response
    }

    func saveYamoneyLoginInStorage(response: YamoneyLoginResponse) -> YamoneyLoginResponse {
        if case .authorized(let data) = response {
            tokenStorage.set(string: data.accessToken, for: Constants.Keys.yamoneyToken)
        }
        return response
    }
}

private extension AuthorizationMediator {
    enum Constants {
        enum Keys {
            static let yandexToken = "yandexToken"
            static let yandexDisplayName = "yandexDisplayName"
            static let yamoneyToken = "yamoneyToken"
            static let isReusableYamoneyToken = "isReusableYamoneyToken"
        }

        static let devHostYandexToken = "AQAAAADvD_dkAAALTqe2-u247kgRomOHDziwAj0"
    }
}

private func makeYamoneyLoginResponse(token: String) -> YamoneyLoginResponse {
    return YamoneyLoginResponse.authorized(.init(accessToken: token))
}

private func makeYandexLoginToken(_ response: YandexLoginResponse) -> String {
    return response.token
}

private func transformTokenIfNeeded(settingsStorage: KeyValueStoring) -> (String) -> String {
    return {
        let isDevHost: Bool = settingsStorage.getBool(for: Settings.Keys.devHost) ?? false
        return isDevHost ? AuthorizationMediator.Constants.devHostYandexToken : $0
    }
}
