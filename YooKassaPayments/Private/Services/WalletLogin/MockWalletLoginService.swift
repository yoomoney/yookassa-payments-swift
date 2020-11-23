import FunctionalSwift
import When
import YooKassaWalletApi
import YooMoneyCoreApi

final class MockWalletLoginService {

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

// MARK: - WalletLoginProcessing

extension MockWalletLoginService: WalletLoginProcessing {
    func requestAuthorization(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        instanceName: String,
        singleAmountMax: MonetaryAmount?,
        paymentUsageLimit: PaymentUsageLimit,
        tmxSessionId: String
    ) -> Promise<WalletLoginResponse> {
        let timeout = makeTimeoutPromise()
        let response = makeWalletLoginResponse(
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
        let response = MockWalletLoginService.accessToken

        if answer == correctAnswer {
            return response <^ timeout

        } else {
            let timeoutResponse = response <^ timeout
            let handleResponse: (String) throws -> String = { _ in
                throw WalletLoginProcessingError.invalidAnswer
            }
            return handleResponse <^> timeoutResponse
        }
    }
}

// MARK: - Making stubs

private let correctAnswer = "1111"

private func makeWalletLoginResponse(
    paymentAuthorizationPassed: Bool
) -> WalletLoginResponse {
    let response: WalletLoginResponse
    if paymentAuthorizationPassed {
        let accessToken = CheckoutTokenIssueExecute(
            accessToken: MockWalletLoginService.accessToken
        )
        response = WalletLoginResponse.authorized(accessToken)
    } else {
        response = WalletLoginResponse.notAuthorized(
            authTypeState: makeAuthTypeState(),
            processId: MockWalletLoginService.processId,
            authContextId: MockWalletLoginService.authContextId
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
