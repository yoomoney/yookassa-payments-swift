import class When.Promise
import FunctionalSwift
import MoneyAuth
import YandexCheckoutWalletApi

final class AuthorizationMediator {

    let tokenStorage: KeyValueStoring
    let yamoneyLoginService: YamoneyLoginProcessing
    let deviceInfoService: DeviceInfoProvider
    let settingsStorage: KeyValueStoring
    let moneyAuthRevokeTokenService: RevokeTokenService?

    init(
        tokenStorage: KeyValueStoring,
        yamoneyLoginService: YamoneyLoginProcessing,
        deviceInfoService: DeviceInfoProvider,
        settingsStorage: KeyValueStoring,
        moneyAuthRevokeTokenService: RevokeTokenService?
    ) {
        self.tokenStorage = tokenStorage
        self.yamoneyLoginService = yamoneyLoginService
        self.deviceInfoService = deviceInfoService
        self.settingsStorage = settingsStorage
        self.moneyAuthRevokeTokenService = moneyAuthRevokeTokenService
    }
}

// MARK: - AuthorizationProcessing

extension AuthorizationMediator: AuthorizationProcessing {
    func getMoneyCenterAuthToken() -> String? {
        return tokenStorage.getString(
            for: KeyValueStoringKeys.moneyCenterAuthToken
        )
    }

    func setMoneyCenterAuthToken(
        _ token: String
    ) {
        tokenStorage.set(
            string: token,
            for: KeyValueStoringKeys.moneyCenterAuthToken
        )
    }

    func getWalletToken() -> String? {
        return tokenStorage.getString(
            for: KeyValueStoringKeys.walletToken
        )
    }

    func getPassportToken() -> String? {
        return tokenStorage.getString(
            for: KeyValueStoringKeys.passportToken
        )
    }

    func hasReusableWalletToken() -> Bool {
        return getWalletToken() != nil
            && tokenStorage.getBool(
                for: KeyValueStoringKeys.isReusableWalletToken
            ) == true
    }

    func logout() {
        if let moneyCenterAuthToken = tokenStorage.getString(
            for: KeyValueStoringKeys.moneyCenterAuthToken
        ) {
            moneyAuthRevokeTokenService?.revoke(
                oauthToken: moneyCenterAuthToken,
                completion: { _ in }
            )
        }
        tokenStorage.set(
            string: nil,
            for: KeyValueStoringKeys.moneyCenterAuthToken
        )
        tokenStorage.set(
            string: nil,
            for: KeyValueStoringKeys.walletToken
        )
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
    func loginInYamoney(
        merchantClientAuthorization: String,
        amount: MonetaryAmount,
        reusableToken: Bool,
        tmxSessionId: String?
    ) -> Promise<YamoneyLoginResponse> {

        if let token = getWalletToken(), hasReusableWalletToken() {
            return Promise { return YamoneyLoginResponse.authorized(CheckoutTokenIssueExecute(accessToken: token)) }
        }

        guard let moneyCenterAuthorization = getMoneyCenterAuthToken() else {
            return Promise { throw AuthorizationProcessingError.passportNotAuthorized }
        }

        tokenStorage.set(
            string: nil,
            for: KeyValueStoringKeys.walletToken
        )
        tokenStorage.set(
            bool: reusableToken,
            for: KeyValueStoringKeys.isReusableWalletToken
        )

        let instanceName = deviceInfoService.getDeviceName()
        let amount = reusableToken ? nil : amount

        let request = curry(yamoneyLoginService.requestAuthorization)
        let authorizedRequest = request(moneyCenterAuthorization)(merchantClientAuthorization)(instanceName)
        let paymentUsageLimit: PaymentUsageLimit = reusableToken ? .multiple : .single

        var promiseTmxSessionId: Promise<String>
        if let tmxSessionId = tmxSessionId {
            promiseTmxSessionId = Promise { return tmxSessionId }
        } else {
            promiseTmxSessionId = ThreatMetrixService.profileApp()
        }

        let response = authorizedRequest(amount)(paymentUsageLimit) -<< promiseTmxSessionId
        return saveYamoneyLoginInStorage <^> response
    }

    func startNewAuthSession(merchantClientAuthorization: String,
                             contextId: String,
                             authType: AuthType) -> Promise<AuthTypeState> {
        guard let moneyCenterAuthorization = getMoneyCenterAuthToken() else {
            return Promise { throw  AuthorizationProcessingError.passportNotAuthorized }
        }

        return yamoneyLoginService.startNewSession(
            moneyCenterAuthorization: moneyCenterAuthorization,
            merchantClientAuthorization: merchantClientAuthorization,
            authContextId: contextId,
            authType: authType
        )
    }

    func checkUserAnswer(
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType,
        answer: String,
        processId: String
    ) -> Promise<YamoneyLoginResponse> {
        guard let moneyCenterAuthorization = getMoneyCenterAuthToken() else {
            return Promise { throw  AuthorizationProcessingError.passportNotAuthorized }
        }

        let token = yamoneyLoginService.checkUserAnswer(
            moneyCenterAuthorization: moneyCenterAuthorization,
            merchantClientAuthorization: merchantClientAuthorization,
            authContextId: authContextId,
            authType: authType,
            answer: answer,
            processId: processId
        )
        let response = makeYamoneyLoginResponse <^> token
        return saveYamoneyLoginInStorage <^> response
    }
}

// MARK: - Private helpers

private extension AuthorizationMediator {
    func saveYamoneyLoginInStorage(
        response: YamoneyLoginResponse
    ) -> YamoneyLoginResponse {
        if case .authorized(let data) = response {
            tokenStorage.set(
                string: data.accessToken,
                for: KeyValueStoringKeys.walletToken
            )
        }
        return response
    }
}

// MARK: - Constants

private extension AuthorizationMediator {
    enum Constants {
        enum Keys {
            static let walletDisplayName = "yandexDisplayName"
        }
    }
}

// MARK: - Private global helpers

private func makeYamoneyLoginResponse(token: String) -> YamoneyLoginResponse {
    return YamoneyLoginResponse.authorized(.init(accessToken: token))
}
