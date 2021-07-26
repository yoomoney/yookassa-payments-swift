struct PaymentAuthorizationModuleInputData {
    let clientApplicationKey: String
    let testModeSettings: TestModeSettings?
    let isLoggingEnabled: Bool
    let moneyAuthClientId: String?

    let authContextId: String
    let processId: String
    let tokenizeScheme: AnalyticsEvent.TokenizeScheme
    let authTypeState: AuthTypeState
}

protocol PaymentAuthorizationModuleInput: AnyObject {}

protocol PaymentAuthorizationModuleOutput: AnyObject {
    func didCheckUserAnswer(
        _ module: PaymentAuthorizationModuleInput,
        response: WalletLoginResponse
    )
}
