import FunctionalSwift
import When
import YandexCheckoutPaymentsApi
import enum YandexCheckoutWalletApi.AuthType

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

    func tokenize(_ data: TokenizeData, paymentOption: PaymentOption) {

        let tmxSessionId = ThreatMetrixService.profileApp()

        let makeToken: (MonetaryAmount?) -> (String) -> Promise<Tokens>

        switch data {
        case let .bankCard(bankCard, confirmation):
            makeToken = curry(paymentService.tokenizeBankCard)(clientApplicationKey)(bankCard)(confirmation)

        case let .wallet(confirmation):

            guard let yamoneyToken = authorizationService.getYamoneyToken() else {
                assertionFailure("You must be authorized in yamoney")
                return
            }

            makeToken = curry(paymentService.tokenizeWallet)(clientApplicationKey)(yamoneyToken)(confirmation)

        case let .linkedBankCard(id, csc, confirmation):

            guard let yamoneyToken = authorizationService.getYamoneyToken() else {
                assertionFailure("You must be authorized in yamoney")
                return
            }

            makeToken = curry(paymentService
                                  .tokenizeLinkedBankCard)(clientApplicationKey)(yamoneyToken)(id)(csc)(confirmation)

        case let .applePay(paymentData):
            makeToken = curry(paymentService.tokenizeApplePay)(clientApplicationKey)(paymentData)

        case let .sberbank(phoneNumber, confirmation):
            makeToken = curry(paymentService.tokenizeSberbank)(clientApplicationKey)(phoneNumber)(confirmation)
        }

        let monetaryAmount = paymentOption.charge
        let tokens = makeToken(monetaryAmount) -<< tmxSessionId
        let tokensWithError = tokens.recover(on: .global(), mapError)

        guard let output = output else { return }
        tokensWithError.done(output.didTokenizeData)
        tokensWithError.fail(output.failTokenizeData)
    }

    func isAuthorizedInYandex() -> Bool {
        return authorizationService.getYandexToken() != nil
    }

    func getYandexDisplayName() -> String? {
        return authorizationService.getYandexDisplayName()
    }

    func loginInYandexMoney(reusableToken: Bool, paymentOption: PaymentOption) {
        let walletMonetaryAmount = MonetaryAmountFactory.makeWalletMonetaryAmount(paymentOption.charge)

        let response = authorizationService.loginInYamoney(merchantClientAuthorization: clientApplicationKey,
                                                           amount: walletMonetaryAmount,
                                                           reusableToken: reusableToken)

        guard let output = output else { return }

        response.done(output.didLoginInYandexMoney)
            .fail(output.failLoginInYandexMoney)
    }

    func resendSmsCode(authContextId: String, authType: AuthType) {
        let authTypeState = authorizationService.startNewAuthSession(merchantClientAuthorization: clientApplicationKey,
                                                                     contextId: authContextId,
                                                                     authType: authType)

        guard let output = output else { return }

        authTypeState.done(output.didResendSmsCode)
            .fail(output.failResendSmsCode)
    }

    func loginInYandexMoney(authContextId: String, authType: AuthType, answer: String, processId: String) {
        let response = authorizationService.checkUserAnswer(merchantClientAuthorization: clientApplicationKey,
                                                            authContextId: authContextId,
                                                            authType: authType,
                                                            answer: answer,
                                                            processId: processId)

        guard let output = output else { return }

        response.done(output.didLoginInYandexMoney)
            .fail(output.failLoginInYandexMoney)
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
    default:
        throw error
    }
}
