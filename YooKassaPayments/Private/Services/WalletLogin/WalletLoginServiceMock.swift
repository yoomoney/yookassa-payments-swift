final class WalletLoginServiceMock {

    // MARK: - Init data

    fileprivate let paymentAuthorizationPassed: Bool

    // MARK: - Init

    init(
        paymentAuthorizationPassed: Bool
    ) {
        self.paymentAuthorizationPassed = paymentAuthorizationPassed
    }

    // MARK: - Mock service settings

    fileprivate static let processId = "processId"
    fileprivate static let authContextId = "authContextId"
    fileprivate static let accessToken = "accessToken"
}

// MARK: - WalletLoginService

extension WalletLoginServiceMock: WalletLoginService {
    func requestAuthorization(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        instanceName: String,
        singleAmountMax: MonetaryAmount?,
        paymentUsageLimit: PaymentUsageLimit,
        tmxSessionId: String,
        completion: @escaping (Result<WalletLoginResponse, Error>) -> Void
    ) {
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
            let response = makeWalletLoginResponse(
                paymentAuthorizationPassed: self.paymentAuthorizationPassed
            )
            completion(.success(response))
        }
    }

    func startNewSession(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType,
        completion: @escaping (Result<AuthTypeState, Error>) -> Void
    ) {
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
            let response = makeAuthTypeState()
            completion(.success(response))
        }
    }

    func checkUserAnswer(
        moneyCenterAuthorization: String,
        merchantClientAuthorization: String,
        authContextId: String,
        authType: AuthType,
        answer: String,
        processId: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
            let response = WalletLoginServiceMock.accessToken
            if answer == correctAnswer {
                completion(.success(response))
            } else {
                completion(.failure(WalletLoginProcessingError.invalidAnswer))
            }
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
            accessToken: WalletLoginServiceMock.accessToken
        )
        response = WalletLoginResponse.authorized(accessToken)
    } else {
        response = WalletLoginResponse.notAuthorized(
            authTypeState: makeAuthTypeState(),
            processId: WalletLoginServiceMock.processId,
            authContextId: WalletLoginServiceMock.authContextId
        )
    }
    return response
}

private func makeAuthTypeState() -> AuthTypeState {
    let smsDescription = Specific.SmsDescription(
        codeLength: 4,
        sessionsLeft: 30,
        sessionTimeLeft: 30,
        nextSessionTimeLeft: 30
    )
    let specific = Specific.sms(smsDescription)
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

private let timeout: Double = 1
