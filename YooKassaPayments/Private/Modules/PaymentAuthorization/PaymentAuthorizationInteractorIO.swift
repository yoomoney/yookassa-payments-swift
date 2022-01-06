/// Interactor input protocol
protocol PaymentAuthorizationInteractorInput {
    func resendCode(authContextId: String, authType: AuthType)

    func checkUserAnswer(
        authContextId: String,
        authType: AuthType,
        answer: String,
        processId: String
    )

    func getWalletPhoneTitle() -> String?

    func track(event: AnalyticsEvent)
    func analyticsAuthType() -> AnalyticsEvent.AuthType
}

/// Interactor output protocol
protocol PaymentAuthorizationInteractorOutput: AnyObject {
    func didResendCode(authTypeState: AuthTypeState)
    func didFailResendCode(_ error: Error)

    func didCheckUserAnswer(_ response: WalletLoginResponse)
    func didFailCheckUserAnswer(_ error: Error)
}
