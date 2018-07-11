import FunctionalSwift
import When
import YandexCheckoutWalletApi
import YandexMoneyCoreApi

final class YamoneyLoginService {

    fileprivate let session: ApiSession
    fileprivate let authTypeStatesService: AuthTypeStatesProvider

    init(session: ApiSession,
         authTypeStatesService: AuthTypeStatesProvider) {
        self.session = session
        self.authTypeStatesService = authTypeStatesService
    }
}

// MARK: - YamoneyLoginProcessing
extension YamoneyLoginService: YamoneyLoginProcessing {

    func requestAuthorization(passportAuthorization: String,
                              merchantClientAuthorization: String,
                              instanceName: String,
                              singleAmountMax: MonetaryAmount?,
                              paymentUsageLimit: PaymentUsageLimit,
                              tmxSessionId: String) -> Promise<YamoneyLoginResponse> {

        func handle(_ response: CheckoutTokenIssueInit) -> Promise<YamoneyLoginResponse> {
            let handler = response.authRequired ? handleAuthRequired : handleAuthNotRequired
            return handler(passportAuthorization, merchantClientAuthorization, response)
        }

        let issueInit = tokenIssueInit(session: session,
                                       passportAuthorization: passportAuthorization,
                                       merchantClientAuthorization: merchantClientAuthorization,
                                       instanceName: instanceName,
                                       singleAmountMax: singleAmountMax,
                                       paymentUsageLimit: paymentUsageLimit,
                                       tmxSessionId: tmxSessionId)

        let response = handle -<< issueInit

        let handledResponse = response.recover(on: .global()) { (error: Error) -> Promise<YamoneyLoginResponse> in
            switch error {
            case YamoneyLoginProcessingError.invalidContext,
                 YamoneyLoginProcessingError.sessionsExceeded:
                return self.requestAuthorization(passportAuthorization: passportAuthorization,
                                                 merchantClientAuthorization: merchantClientAuthorization,
                                                 instanceName: instanceName,
                                                 singleAmountMax: singleAmountMax,
                                                 paymentUsageLimit: paymentUsageLimit,
                                                 tmxSessionId: tmxSessionId)
            default:
                throw error
            }
        }
        return handledResponse
    }

    func startNewSession(passportAuthorization: String,
                         merchantClientAuthorization: String,
                         authContextId: String,
                         authType: AuthType) -> Promise<AuthTypeState> {
        let response = authSessionGenerate(session: session,
                                           passportAuthorization: passportAuthorization,
                                           merchantClientAuthorization: merchantClientAuthorization,
                                           authContextId: authContextId,
                                           authType: authType)
        let responseWithErrors: Promise<CheckoutAuthSessionGenerate> = response.recover(mapError)
        return unpackAuthTypeState <^> responseWithErrors
    }

    func checkUserAnswer(passportAuthorization: String,
                         merchantClientAuthorization: String,
                         authContextId: String,
                         authType: AuthType,
                         answer: String,
                         processId: String) -> Promise<String> {
        let authCheckResponse = authCheck(session: session,
                                          passportAuthorization: passportAuthorization,
                                          merchantClientAuthorization: merchantClientAuthorization,
                                          authContextId: authContextId,
                                          authType: authType,
                                          answer: answer)

        let executeCurry = curry(execute)(session)(passportAuthorization)(merchantClientAuthorization)(processId)
        let accessToken = executeCurry -<< authCheckResponse
        let accessTokenWithErrors = accessToken.recover(mapError)
        return accessTokenWithErrors
    }
}

private extension YamoneyLoginService {

    func handleAuthNotRequired(passportAuthorization: String,
                               merchantClientAuthorization: String,
                               response: CheckoutTokenIssueInit) -> Promise<YamoneyLoginResponse> {
        let response = tokenIssueExecute(session: session,
                                         passportAuthorization: passportAuthorization,
                                         merchantClientAuthorization: merchantClientAuthorization,
                                         processId: response.processId)
        let responseWithErrors = response.recover(mapError)
        return makeResponse <^> responseWithErrors
    }

    func handleAuthRequired(passportAuthorization: String,
                            merchantClientAuthorization: String,
                            checkoutTokenIssueInit: CheckoutTokenIssueInit) -> Promise<YamoneyLoginResponse> {
        let processId = checkoutTokenIssueInit.processId
        let authContextId = checkoutTokenIssueInit.authContextId
        let context = authContextGet(session: session,
                                     passportAuthorization: passportAuthorization,
                                     merchantClientAuthorization: merchantClientAuthorization,
                                     authContextId: authContextId)

        let contextWithErrors = context.recover(mapError)

        let states = unpackAuthTypeStates <^> contextWithErrors
        let filteredStates = authTypeStatesService.filterStates <^> states
        let selectedState = authTypeStatesService.preferredAuthTypeState <^> filteredStates
        let generateSession
            = curry(generateSessionIfNeeded)(session)(passportAuthorization)(merchantClientAuthorization)
        let sessionWithContext = generateSession(authContextId) -<< selectedState
        return { makeResponse($0, processId, authContextId) } <^> sessionWithContext
    }
}

// MARK: - Service logic

private func generateSessionIfNeeded(session: ApiSession,
                                     passportAuthorization: String,
                                     merchantClientAuthorization: String,
                                     authContextId: String,
                                     state: AuthTypeState) -> Promise<AuthTypeState> {
    switch state.isSessionRequired {
    case true:
        let response = authSessionGenerate(session: session,
                                           passportAuthorization: passportAuthorization,
                                           merchantClientAuthorization: merchantClientAuthorization,
                                           authContextId: authContextId,
                                           authType: state.specific.type)
        let responseWithErrors = response.recover(mapError)
        return { $0.result } <^> responseWithErrors
    case false:
        return id(state)
    }
}

private func execute(session: ApiSession,
                     passportAuthorization: String,
                     merchantClientAuthorization: String,
                     processId: String,
                     authCheck _: CheckoutAuthCheck) -> Promise<String> {
    let execute = tokenIssueExecute(session: session,
                                    passportAuthorization: passportAuthorization,
                                    merchantClientAuthorization: merchantClientAuthorization,
                                    processId: processId)
    let executeWithErrors = execute.recover(mapError)
    return { $0.accessToken } <^> executeWithErrors
}

// MARK: - Service helper

private func makeResponse(_ value: CheckoutTokenIssueExecute) -> YamoneyLoginResponse {
    return YamoneyLoginResponse.authorized(value)
}

private func makeResponse(_ value: AuthTypeState, _ processId: String, _ contextId: String) -> YamoneyLoginResponse {
    return YamoneyLoginResponse.notAuthorized(authTypeState: value,
                                              processId: processId,
                                              authContextId: contextId)
}

private func unpackAuthTypeStates(_ context: CheckoutAuthContextGet) -> [AuthTypeState] {
    return context.authTypes
}

private func unpackAuthTypeState(_ response: CheckoutAuthSessionGenerate) -> AuthTypeState {
    return response.result
}

// MARK: - Errors

private func mapError<T>(_ error: Error) throws -> Promise<T> {

    let resultError: Error

    switch error {

    case CheckoutAuthCheckError.invalidAnswer:
        resultError = YamoneyLoginProcessingError.invalidAnswer

    case CheckoutAuthContextGetError.invalidContext,
         CheckoutAuthSessionGenerateError.invalidContext:
        resultError = YamoneyLoginProcessingError.invalidContext

    case CheckoutAuthCheckError.invalidContext:
        resultError = YamoneyLoginProcessingError.authCheckInvalidContext

    case CheckoutAuthSessionGenerateError.sessionsExceeded:
        resultError = YamoneyLoginProcessingError.sessionsExceeded

    case CheckoutAuthCheckError.sessionDoesNotExist,
         CheckoutAuthCheckError.sessionExpired:
        resultError = YamoneyLoginProcessingError.sessionDoesNotExist

    case CheckoutAuthCheckError.verifyAttemptsExceeded:
        resultError = YamoneyLoginProcessingError.verifyAttemptsExceeded

    case CheckoutTokenIssueExecuteError.authRequired,
         CheckoutTokenIssueExecuteError.authExpired:
        resultError = YamoneyLoginProcessingError.executeError

    default:
        resultError = error
    }

    throw resultError
}

// MARK: - Promise helper

private func id<T>(_ value: T) -> Promise<T> {
    let promise = Promise<T>()
    promise.resolve(value)
    return promise
}

// MARK: - API methods

private func tokenIssueInit(session: ApiSession,
                            passportAuthorization: String,
                            merchantClientAuthorization: String,
                            instanceName: String,
                            singleAmountMax: MonetaryAmount?,
                            paymentUsageLimit: PaymentUsageLimit,
                            tmxSessionId: String) -> Promise<CheckoutTokenIssueInit> {
    let method = CheckoutTokenIssueInit.Method(passportAuthorization: passportAuthorization,
                                               merchantClientAuthorization: merchantClientAuthorization,
                                               instanceName: instanceName,
                                               singleAmountMax: singleAmountMax,
                                               paymentUsageLimit: paymentUsageLimit,
                                               tmxSessionId: tmxSessionId)
    return session.perform(apiMethod: method).responseApi()
}

private func authContextGet(session: ApiSession,
                            passportAuthorization: String,
                            merchantClientAuthorization: String,
                            authContextId: String) -> Promise<CheckoutAuthContextGet> {
    let method = CheckoutAuthContextGet.Method(passportAuthorization: passportAuthorization,
                                               merchantClientAuthorization: merchantClientAuthorization,
                                               authContextId: authContextId)
    return session.perform(apiMethod: method).responseApi()
}

private func authSessionGenerate(session: ApiSession,
                                 passportAuthorization: String,
                                 merchantClientAuthorization: String,
                                 authContextId: String,
                                 authType: AuthType) -> Promise<CheckoutAuthSessionGenerate> {
    let method = CheckoutAuthSessionGenerate.Method(passportAuthorization: passportAuthorization,
                                                    merchantClientAuthorization: merchantClientAuthorization,
                                                    authContextId: authContextId,
                                                    authType: authType)
    return session.perform(apiMethod: method).responseApi()
}

private func authCheck(session: ApiSession,
                       passportAuthorization: String,
                       merchantClientAuthorization: String,
                       authContextId: String,
                       authType: AuthType,
                       answer: String) -> Promise<CheckoutAuthCheck> {
    let method = CheckoutAuthCheck.Method(passportAuthorization: passportAuthorization,
                                          merchantClientAuthorization: merchantClientAuthorization,
                                          authContextId: authContextId,
                                          authType: authType,
                                          answer: answer)
    return session.perform(apiMethod: method).responseApi()
}

private func tokenIssueExecute(session: ApiSession,
                               passportAuthorization: String,
                               merchantClientAuthorization: String,
                               processId: String) -> Promise<CheckoutTokenIssueExecute> {
    let method = CheckoutTokenIssueExecute.Method(passportAuthorization: passportAuthorization,
                                                  merchantClientAuthorization: merchantClientAuthorization,
                                                  processId: processId)
    return session.perform(apiMethod: method).responseApi()
}
