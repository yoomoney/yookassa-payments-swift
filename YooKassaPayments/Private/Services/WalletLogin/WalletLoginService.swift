import YooKassaWalletApi

protocol WalletLoginService {
    func requestAuthorization(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        instanceName: String,
        singleAmountMax: MonetaryAmount?,
        paymentUsageLimit: PaymentUsageLimit,
        tmxSessionId: String,
        completion: @escaping (Result<WalletLoginResponse, Error>) -> Void
    )

    func startNewSession(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType,
        completion: @escaping (Result<AuthTypeState, Error>) -> Void
    )

    func checkUserAnswer(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType,
        answer: String,
        processId: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
}
