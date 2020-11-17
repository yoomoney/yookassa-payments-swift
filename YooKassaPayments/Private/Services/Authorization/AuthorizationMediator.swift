import class When.Promise
import FunctionalSwift
import MoneyAuth
import YooKassaWalletApi

final class AuthorizationMediator {

    let tokenStorage: KeyValueStoring
    let walletLoginService: WalletLoginProcessing
    let deviceInfoService: DeviceInfoProvider
    let settingsStorage: KeyValueStoring
    let moneyAuthRevokeTokenService: RevokeTokenService?

    init(
        tokenStorage: KeyValueStoring,
        walletLoginService: WalletLoginProcessing,
        deviceInfoService: DeviceInfoProvider,
        settingsStorage: KeyValueStoring,
        moneyAuthRevokeTokenService: RevokeTokenService?
    ) {
        self.tokenStorage = tokenStorage
        self.walletLoginService = walletLoginService
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
    func loginInWallet(
        merchantClientAuthorization: String,
        amount: MonetaryAmount,
        reusableToken: Bool,
        tmxSessionId: String?
    ) -> Promise<WalletLoginResponse> {

        if let token = getWalletToken(), hasReusableWalletToken() {
            return Promise { return WalletLoginResponse.authorized(CheckoutTokenIssueExecute(accessToken: token)) }
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

        let request = curry(walletLoginService.requestAuthorization)
        let authorizedRequest = request(moneyCenterAuthorization)(merchantClientAuthorization)(instanceName)
        let paymentUsageLimit: PaymentUsageLimit = reusableToken ? .multiple : .single

        var promiseTmxSessionId: Promise<String>
        if let tmxSessionId = tmxSessionId {
            promiseTmxSessionId = Promise { return tmxSessionId }
        } else {
            promiseTmxSessionId = ThreatMetrixService.profileApp()
        }

        let response = authorizedRequest(amount)(paymentUsageLimit) -<< promiseTmxSessionId
        return saveWalletLoginInStorage <^> response
    }

    func startNewAuthSession(merchantClientAuthorization: String,
                             contextId: String,
                             authType: AuthType) -> Promise<AuthTypeState> {
        guard let moneyCenterAuthorization = getMoneyCenterAuthToken() else {
            return Promise { throw  AuthorizationProcessingError.passportNotAuthorized }
        }

        return walletLoginService.startNewSession(
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
    ) -> Promise<WalletLoginResponse> {
        guard let moneyCenterAuthorization = getMoneyCenterAuthToken() else {
            return Promise { throw  AuthorizationProcessingError.passportNotAuthorized }
        }

        let token = walletLoginService.checkUserAnswer(
            moneyCenterAuthorization: moneyCenterAuthorization,
            merchantClientAuthorization: merchantClientAuthorization,
            authContextId: authContextId,
            authType: authType,
            answer: answer,
            processId: processId
        )
        let response = makeWalletLoginResponse <^> token
        return saveWalletLoginInStorage <^> response
    }
}

// MARK: - Private helpers

private extension AuthorizationMediator {
    func saveWalletLoginInStorage(
        response: WalletLoginResponse
    ) -> WalletLoginResponse {
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
            static let walletDisplayName = "walletDisplayName"
        }
    }
}

// MARK: - Private global helpers

private func makeWalletLoginResponse(token: String) -> WalletLoginResponse {
    return WalletLoginResponse.authorized(.init(accessToken: token))
}
