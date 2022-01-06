protocol LinkedCardInteractorInput {
    func loginInWallet(
        amount: MonetaryAmount,
        reusableToken: Bool,
        tmxSessionId: String?
    )

    func tokenize(
        id: String,
        csc: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount,
        tmxSessionId: String?
    )

    func hasReusableWalletToken() -> Bool

    func track(event: AnalyticsEvent)
    func analyticsAuthType() -> AnalyticsEvent.AuthType
}

protocol LinkedCardInteractorOutput: AnyObject {
    func didLoginInWallet(
        _ response: WalletLoginResponse
    )
    func failLoginInWallet(
        _ error: Error
    )

    func didTokenizeData(
        _ token: Tokens
    )
    func failTokenizeData(
        _ error: Error
    )
}
