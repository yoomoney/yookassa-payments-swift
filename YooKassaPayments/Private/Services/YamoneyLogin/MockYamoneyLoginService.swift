import FunctionalSwift
import When
import YooKassaWalletApi
import YooMoneyCoreApi

final class MockYamoneyLoginService {

    // MARK: - Data

    fileprivate let paymentAuthorizationPassed: Bool

    // MARK: - Initializers & deinitializer

    init(paymentAuthorizationPassed: Bool) {
        self.paymentAuthorizationPassed = paymentAuthorizationPassed
    }

    // MARK: - Mock service settings

    fileprivate static let processId = "processId"
    fileprivate static let authContextId = "authContextId"
    fileprivate static let accessToken = "accessToken"
}

// MARK: - YamoneyLoginProcessing

extension MockYamoneyLoginService: YamoneyLoginProcessing {
    func requestAuthorization(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        instanceName: String,
        singleAmountMax: MonetaryAmount?,
        paymentUsageLimit: PaymentUsageLimit,
        tmxSessionId: String
    ) -> Promise<YamoneyLoginResponse> {
        let timeout = makeTimeoutPromise()
        let response = makeYamoneyLoginResponse(
            paymentAuthorizationPassed: self.paymentAuthorizationPassed
        )
        return response <^ timeout
    }

    func startNewSession(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType
    ) -> Promise<AuthTypeState> {
        let timeout = makeTimeoutPromise()
        let response = makeAuthTypeState()
        return response <^ timeout
    }

    func checkUserAnswer(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType,
        answer: String,
        processId: String
    ) -> Promise<String> {
        let timeout = makeTimeoutPromise()
        let response = MockYamoneyLoginService.accessToken

        if answer == correctAnswer {
            return response <^ timeout

        } else {
            let timeoutResponse = response <^ timeout
            let handleResponse: (String) throws -> String = { _ in
                throw YamoneyLoginProcessingError.invalidAnswer
            }
            return handleResponse <^> timeoutResponse
        }
    }
}

// MARK: - Making stubs

private let correctAnswer = "1111"

private func makeYamoneyLoginResponse(
    paymentAuthorizationPassed: Bool
) -> YamoneyLoginResponse {
    let response: YamoneyLoginResponse
    if paymentAuthorizationPassed {
        let accessToken = CheckoutTokenIssueExecute(
            accessToken: MockYamoneyLoginService.accessToken
        )
        response = YamoneyLoginResponse.authorized(accessToken)
    } else {
        response = YamoneyLoginResponse.notAuthorized(
            authTypeState: makeAuthTypeState(),
            processId: MockYamoneyLoginService.processId,
            authContextId: MockYamoneyLoginService.authContextId
        )
    }
    return response
}

private func makeAuthTypeState() -> AuthTypeState {
    let smsDescription = AuthTypeState.Specific.SmsDescription(
        codeLength: 4,
        sessionsLeft: 30,
        sessionTimeLeft: 30,
        nextSessionTimeLeft: 30
    )
    let specific = AuthTypeState.Specific.sms(smsDescription)
    let authTypeState = AuthTypeState(
        specific: specific,
        activeSession: nil,
        canBeIssued: true,
        enabled: true,
        isSessionRequired: true
    )
    return authTypeState
}

// MARK: - Promise helper

private let timeout: Double = 2

private func makeTimeoutPromise() -> Promise<()> {
    let promise: Promise<()> = Promise()
    DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
        promise.resolve(())
    }
    return promise
}
