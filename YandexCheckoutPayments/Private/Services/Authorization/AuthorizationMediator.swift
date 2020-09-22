import class When.Promise
import FunctionalSwift
import YandexCheckoutWalletApi

final class AuthorizationMediator {

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
}

// MARK: - AuthorizationProcessing

extension AuthorizationMediator: AuthorizationProcessing {
    func getMoneyCenterAuthToken() -> String? {
        let token = tokenStorage.getString(for: Constants.Keys.moneyCenterAuthToken)
        return transformTokenIfNeeded(settingsStorage: settingsStorage) <^> token
    }

    func setMoneyCenterAuthToken(
        _ token: String
    ) {
        tokenStorage.set(string: token, for: Constants.Keys.moneyCenterAuthToken)
    }

    func getWalletToken() -> String? {
        return tokenStorage.getString(for: Constants.Keys.walletToken)
    }

    func setWalletToken(
        _ token: String
    ) {
        tokenStorage.set(string: token, for: Constants.Keys.walletToken)
    }

    func hasReusableWalletToken() -> Bool {
        return getWalletToken() != nil
            && tokenStorage.getBool(
            for: Constants.Keys.isReusableWalletToken
        ) == true
    }

    func logout() {
        tokenStorage.set(string: nil, for: Constants.Keys.moneyCenterAuthToken)
        tokenStorage.set(string: nil, for: Constants.Keys.walletToken)
    }

    func setWalletDisplayName(
        _ walletDisplayName: String?
    ) {
        tokenStorage.set(
            string: walletDisplayName,
            for: Constants.Keys.walletDisplayName
        )
    }

    func getWalletDisplayName() -> String? {
        tokenStorage.getString(
            for: Constants.Keys.walletDisplayName
        )
    }
}

// MARK: - AuthorizationProcessing Wallet 2FA

extension AuthorizationMediator {
    func loginInYamoney(merchantClientAuthorization: String,
                        amount: MonetaryAmount,
                        reusableToken: Bool) -> Promise<YamoneyLoginResponse> {

        if let token = getWalletToken(), hasReusableWalletToken() {
            return Promise { return YamoneyLoginResponse.authorized(CheckoutTokenIssueExecute(accessToken: token)) }
        }

        // TODO: MOC-1014 (Change passportAuthorization to moneyCenterAuthToken)
        guard let passportAuthorization = getMoneyCenterAuthToken() else {
            return Promise { throw AuthorizationProcessingError.passportNotAuthorized }
        }

        tokenStorage.set(string: nil, for: Constants.Keys.walletToken)
        tokenStorage.set(bool: reusableToken, for: Constants.Keys.isReusableWalletToken)

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
        // TODO: MOC-1014 (Change passportAuthorization to moneyCenterAuthToken)
        guard let passportAuthorization = getMoneyCenterAuthToken() else {
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
        // TODO: MOC-1014 (Change passportAuthorization to moneyCenterAuthToken)
        guard let passportAuthorization = getMoneyCenterAuthToken() else {
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
}

// MARK: - Private helpers

private extension AuthorizationMediator {
    func saveYamoneyLoginInStorage(response: YamoneyLoginResponse) -> YamoneyLoginResponse {
        if case .authorized(let data) = response {
            tokenStorage.set(string: data.accessToken, for: Constants.Keys.walletToken)
        }
        return response
    }
}

// MARK: - Constants

private extension AuthorizationMediator {
    enum Constants {
        enum Keys {
            static let moneyCenterAuthToken = "yandexToken"
            static let walletToken = "yamoneyToken"
            static let isReusableWalletToken = "isReusableYamoneyToken"
            static let walletDisplayName = "walletDisplayName"
        }

        static let devHostMoneyCenterAuthToken = "AQAAAADvD_dkAAALTqe2-u247kgRomOHDziwAj0"
    }
}

// MARK: - Private global helpers

private func makeYamoneyLoginResponse(token: String) -> YamoneyLoginResponse {
    return YamoneyLoginResponse.authorized(.init(accessToken: token))
}

private func transformTokenIfNeeded(settingsStorage: KeyValueStoring) -> (String) -> String {
    return {
        let isDevHost: Bool = settingsStorage.getBool(for: Settings.Keys.devHost) ?? false
        return isDevHost ? AuthorizationMediator.Constants.devHostMoneyCenterAuthToken : $0
    }
}
