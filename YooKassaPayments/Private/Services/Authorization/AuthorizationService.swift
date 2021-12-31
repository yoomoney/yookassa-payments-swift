protocol AuthorizationService {
    func getMoneyCenterAuthToken() -> String?

    func setMoneyCenterAuthToken(_ token: String)

    func getWalletToken() -> String?

    func hasReusableWalletToken() -> Bool

    func logout()

    func setWalletDisplayName(_ walletDisplayName: String?)

    func getWalletDisplayName() -> String?

    func setWalletPhoneTitle(_ walletPhoneTitle: String?)

    func getWalletPhoneTitle() -> String?

    func setWalletAvatarURL(_ walletAvatarURL: String?)

    func getWalletAvatarURL() -> String?

    func analyticsAuthType() -> AnalyticsEvent.AuthType

    // MARK: - Wallet 2FA

    func loginInWallet(
        merchantClientAuthorization: String,
        amount: MonetaryAmount,
        reusableToken: Bool,
        tmxSessionId: String?,
        completion: @escaping (Result<WalletLoginResponse, Error>) -> Void
    )

    func startNewAuthSession(
        merchantClientAuthorization: String,
        contextId: String,
        authType: AuthType,
        completion: @escaping (Result<AuthTypeState, Error>) -> Void
    )

    func checkUserAnswer(
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType,
        answer: String,
        processId: String,
        completion: @escaping (Result<WalletLoginResponse, Error>) -> Void
    )
}
