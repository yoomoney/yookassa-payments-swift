import FunctionalSwift
import When
import YooKassaPaymentsApi
import enum YooKassaWalletApi.AuthType

final class TokenizationInteractor {

    // MARK: - VIPER module

    weak var output: TokenizationInteractorOutput?
    private let paymentService: PaymentProcessing
    private let authorizationService: AuthorizationProcessing
    private let analyticsService: AnalyticsProcessing
    private let analyticsProvider: AnalyticsProviding

    // MARK: - Data properties

    private let clientApplicationKey: String

    init(paymentService: PaymentProcessing,
         authorizationService: AuthorizationProcessing,
         analyticsService: AnalyticsProcessing,
         analyticsProvider: AnalyticsProviding,
         clientApplicationKey: String) {
        ThreatMetrixService.configure()

        self.clientApplicationKey = clientApplicationKey
        self.paymentService = paymentService
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider
    }
}

// MARK: - TokenizationInteractorInput

extension TokenizationInteractor: TokenizationInteractorInput {

    func tokenize(
        _ data: TokenizeData,
        paymentOption: PaymentOption,
        tmxSessionId: String?
    ) {
        let promiseTmxSessionId: Promise<String>
        if let tmxSessionId = tmxSessionId {
            promiseTmxSessionId = Promise { return tmxSessionId }
        } else {
            promiseTmxSessionId = ThreatMetrixService.profileApp()
        }

        let makeToken: (MonetaryAmount?) -> (String) -> Promise<Tokens>

        switch data {
        case let .bankCard(bankCard, confirmation, savePaymentMethod):
            makeToken = curry(
                paymentService.tokenizeBankCard)(clientApplicationKey)(
                    bankCard)(confirmation)(savePaymentMethod)

        case let .wallet(confirmation, savePaymentMethod):

            guard let yamoneyToken = authorizationService.getWalletToken() else {
                assertionFailure("You must be authorized in yamoney")
                return
            }

            makeToken = curry(paymentService.tokenizeWallet)(clientApplicationKey)(
                yamoneyToken)(confirmation)(savePaymentMethod)(paymentOption.paymentMethodType)

        case let .linkedBankCard(id, csc, confirmation, savePaymentMethod):

            guard let yamoneyToken = authorizationService.getWalletToken() else {
                assertionFailure("You must be authorized in yamoney")
                return
            }

            makeToken = curry(paymentService.tokenizeLinkedBankCard)(clientApplicationKey)(
                yamoneyToken)(id)(csc)(confirmation)(savePaymentMethod)(paymentOption.paymentMethodType)

        case let .applePay(paymentData, savePaymentMethod):
            makeToken = curry(paymentService.tokenizeApplePay)(clientApplicationKey)(
                paymentData)(savePaymentMethod)

        case let .sberbank(phoneNumber, confirmation, savePaymentMethod):
            makeToken = curry(paymentService.tokenizeSberbank)(clientApplicationKey)(
                phoneNumber)(confirmation)(savePaymentMethod)
        }

        let monetaryAmount = paymentOption.charge
        let tokens = makeToken(monetaryAmount) -<< promiseTmxSessionId
        let tokensWithError = tokens.recover(on: .global(), mapError)

        guard let output = output else { return }
        tokensWithError.done(output.didTokenizeData)
        tokensWithError.fail(output.failTokenizeData)
    }

    func getWalletDisplayName() -> String? {
        return authorizationService.getWalletDisplayName()
    }

    func loginInWallet(
        reusableToken: Bool,
        paymentOption: PaymentOption,
        tmxSessionId: String?
    ) {
        let walletMonetaryAmount = MonetaryAmountFactory.makeWalletMonetaryAmount(paymentOption.charge)

        let response = authorizationService.loginInYamoney(
            merchantClientAuthorization: clientApplicationKey,
            amount: walletMonetaryAmount,
            reusableToken: reusableToken,
            tmxSessionId: tmxSessionId
        )
        let responseWithError = response.recover(on: .global(), mapError)

        guard let output = output else { return }

        responseWithError.done(output.didLoginInWallet)
        responseWithError.fail(output.failLoginInWallet)
    }

    func resendSmsCode(authContextId: String, authType: AuthType) {
        let authTypeState = authorizationService.startNewAuthSession(merchantClientAuthorization: clientApplicationKey,
                                                                     contextId: authContextId,
                                                                     authType: authType)

        guard let output = output else { return }

        authTypeState.done(output.didResendSmsCode)
            .fail(output.failResendSmsCode)
    }

    func loginInWallet(authContextId: String, authType: AuthType, answer: String, processId: String) {
        let response = authorizationService.checkUserAnswer(merchantClientAuthorization: clientApplicationKey,
                                                            authContextId: authContextId,
                                                            authType: authType,
                                                            answer: answer,
                                                            processId: processId)

        let responseWithError = response.recover(on: .global(), mapError)

        guard let output = output else { return }

        responseWithError.done(output.didLoginInWallet)
        responseWithError.fail(output.failLoginInWallet)
    }

    func logout() {
        authorizationService.logout()
    }

    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }

    func makeTypeAnalyticsParameters() -> (authType: AnalyticsEvent.AuthType,
                                           tokenType: AnalyticsEvent.AuthTokenType?) {
        return analyticsProvider.makeTypeAnalyticsParameters()
    }

    func startAnalyticsService() {
        analyticsService.start()

    }

    func stopAnalyticsService() {
        analyticsService.stop()
    }
}

private func mapError<T>(_ error: Error) throws -> Promise<T> {
    switch error {
    case ThreatMetrixService.ProfileError.connectionFail:
        throw PaymentProcessingError.internetConnection
    case let error as NSError where error.domain == NSURLErrorDomain:
        throw PaymentProcessingError.internetConnection
    default:
        throw error
    }
}
