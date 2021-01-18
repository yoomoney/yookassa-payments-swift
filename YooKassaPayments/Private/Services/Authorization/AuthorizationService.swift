import enum YooKassaWalletApi.AuthType
import struct YooKassaWalletApi.AuthTypeState
import struct YooKassaWalletApi.MonetaryAmount

protocol AuthorizationService {
    func getMoneyCenterAuthToken() -> String?

    func setMoneyCenterAuthToken(
        _ token: String
    )

    func getWalletToken() -> String?

    func hasReusableWalletToken() -> Bool

    func logout()

    func setWalletDisplayName(
        _ walletDisplayName: String?
    )

    func getWalletDisplayName() -> String?

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
