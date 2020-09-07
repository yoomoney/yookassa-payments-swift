import class When.Promise
import FunctionalSwift
import YandexCheckoutWalletApi

final class AuthorizationMediator: AuthorizationProcessing {

    let tokenStorage: KeyValueStoring
    let yamoneyLoginService: YamoneyLoginProcessing
    let deviceInfoService: DeviceInfoProvider
    let settingsStorage: KeyValueStoring

    init(
        tokenStorage: KeyValueStoring,
        yamoneyLoginService: YamoneyLoginProcessing,
        deviceInfoService: DeviceInfoProvider,
        settingsStorage: KeyValueStoring
    ) {
        self.tokenStorage = tokenStorage
        self.yamoneyLoginService = yamoneyLoginService
        self.deviceInfoService = deviceInfoService
        self.settingsStorage = settingsStorage
    }

    func getYamoneyToken() -> String? {
        return tokenStorage.getString(for: Constants.Keys.yamoneyToken)
    }

    func hasReusableYamoneyToken() -> Bool {
        return getYamoneyToken() != nil && tokenStorage.getBool(for: Constants.Keys.isReusableYamoneyToken) == true
    }

    func loginInYamoney(merchantClientAuthorization: String,
                        amount: MonetaryAmount,
                        reusableToken: Bool) -> Promise<YamoneyLoginResponse> {

        if let token = getYamoneyToken(), hasReusableYamoneyToken() {
            return Promise { return YamoneyLoginResponse.authorized(CheckoutTokenIssueExecute(accessToken: token)) }
        }

        // TODO: MOC-1012
        let passportAuthorization = "TODO"
//        guard let passportAuthorization = getYandexToken() else {
//            return Promise { throw AuthorizationProcessingError.passportNotAuthorized }
//        }

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
        // TODO: MOC-1012
        let passportAuthorization = "TODO"
//        guard let passportAuthorization = getYandexToken() else {
//            return Promise { throw  AuthorizationProcessingError.passportNotAuthorized }
//        }

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
        // TODO: MOC-1012
        let passportAuthorization = "TODO"
//        guard let passportAuthorization = getYandexToken() else {
//            return Promise { throw  AuthorizationProcessingError.passportNotAuthorized }
//        }

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
        tokenStorage.set(string: nil, for: Constants.Keys.yamoneyToken)
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
            static let yamoneyToken = "yamoneyToken"
            static let isReusableYamoneyToken = "isReusableYamoneyToken"
        }
    }
}

private func makeYamoneyLoginResponse(token: String) -> YamoneyLoginResponse {
    return YamoneyLoginResponse.authorized(.init(accessToken: token))
}
