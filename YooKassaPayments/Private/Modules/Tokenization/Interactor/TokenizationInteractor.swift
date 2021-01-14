import When
import YooKassaPaymentsApi
import enum YooKassaWalletApi.AuthType

final class TokenizationInteractor {

    // MARK: - VIPER module

    weak var output: TokenizationInteractorOutput?
    private let paymentService: PaymentService
    private let authorizationService: AuthorizationProcessing
    private let analyticsService: AnalyticsProcessing
    private let analyticsProvider: AnalyticsProviding

    // MARK: - Data properties

    private let clientApplicationKey: String

    init(
        paymentService: PaymentService,
        authorizationService: AuthorizationProcessing,
        analyticsService: AnalyticsProcessing,
        analyticsProvider: AnalyticsProviding,
        clientApplicationKey: String
    ) {
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

    // swiftlint:disable cyclomatic_complexity
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

        promiseTmxSessionId.always { [weak self] result in
            guard let self = self,
                  let output = self.output else { return }

            let monetaryAmount = paymentOption.charge

            switch result {
            case let .success(tmxSessionId):
                let completion: (Swift.Result<Tokens, Error>) -> Void = { result in
                    switch result {
                    case .success(let data):
                        output.didTokenizeData(data)
                    case .failure(let error):
                        let mappedError = mapError(error)
                        output.failTokenizeData(mappedError)
                    }
                }

                switch data {
                case let .bankCard(bankCard, confirmation, savePaymentMethod):
                    self.paymentService.tokenizeBankCard(
                        clientApplicationKey: self.clientApplicationKey,
                        bankCard: bankCard,
                        confirmation: confirmation,
                        savePaymentMethod: savePaymentMethod,
                        amount: monetaryAmount,
                        tmxSessionId: tmxSessionId,
                        completion: completion
                    )

                case let .wallet(confirmation, savePaymentMethod):
                    guard let walletToken = self.authorizationService.getWalletToken() else {
                        assertionFailure("You must be authorized in wallet")
                        return
                    }

                    self.paymentService.tokenizeWallet(
                        clientApplicationKey: self.clientApplicationKey,
                        walletAuthorization: walletToken,
                        confirmation: confirmation,
                        savePaymentMethod: savePaymentMethod,
                        paymentMethodType: paymentOption.paymentMethodType,
                        amount: monetaryAmount,
                        tmxSessionId: tmxSessionId,
                        completion: completion
                    )

                case let .linkedBankCard(id, csc, confirmation, savePaymentMethod):
                    guard let walletToken = self.authorizationService.getWalletToken() else {
                        assertionFailure("You must be authorized in wallet")
                        return
                    }

                    self.paymentService.tokenizeLinkedBankCard(
                        clientApplicationKey: self.clientApplicationKey,
                        walletAuthorization: walletToken,
                        cardId: id,
                        csc: csc,
                        confirmation: confirmation,
                        savePaymentMethod: savePaymentMethod,
                        paymentMethodType: paymentOption.paymentMethodType,
                        amount: monetaryAmount,
                        tmxSessionId: tmxSessionId,
                        completion: completion
                    )

                case let .applePay(paymentData, savePaymentMethod):
                    self.paymentService.tokenizeApplePay(
                        clientApplicationKey: self.clientApplicationKey,
                        paymentData: paymentData,
                        savePaymentMethod: savePaymentMethod,
                        amount: monetaryAmount,
                        tmxSessionId: tmxSessionId,
                        completion: completion
                    )

                case let .sberbank(phoneNumber, confirmation, savePaymentMethod):
                    self.paymentService.tokenizeSberbank(
                        clientApplicationKey: self.clientApplicationKey,
                        phoneNumber: phoneNumber,
                        confirmation: confirmation,
                        savePaymentMethod: savePaymentMethod,
                        amount: monetaryAmount,
                        tmxSessionId: tmxSessionId,
                        completion: completion
                    )
                }

            case let .failure(error):
                let mappedError = mapError(error)
                output.failTokenizeData(mappedError)
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func getWalletDisplayName() -> String? {
        return authorizationService.getWalletDisplayName()
    }

    func loginInWallet(
        reusableToken: Bool,
        paymentOption: PaymentOption,
        tmxSessionId: String?
    ) {
        let walletMonetaryAmount = MonetaryAmountFactory
            .makeWalletMonetaryAmount(paymentOption.charge)

        let response = authorizationService.loginInWallet(
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
        let authTypeState = authorizationService.startNewAuthSession(
            merchantClientAuthorization: clientApplicationKey,
            contextId: authContextId,
            authType: authType
        )

        guard let output = output else { return }

        authTypeState.done(output.didResendSmsCode)
            .fail(output.failResendSmsCode)
    }

    func loginInWallet(authContextId: String, authType: AuthType, answer: String, processId: String) {
        let response = authorizationService.checkUserAnswer(
            merchantClientAuthorization: clientApplicationKey,
            authContextId: authContextId,
            authType: authType,
            answer: answer,
            processId: processId
        )

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

private func mapError(_ error: Error) -> Error {
    switch error {
    case ThreatMetrixService.ProfileError.connectionFail:
        return PaymentProcessingError.internetConnection
    case let error as NSError where error.domain == NSURLErrorDomain:
        return PaymentProcessingError.internetConnection
    default:
        return error
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
