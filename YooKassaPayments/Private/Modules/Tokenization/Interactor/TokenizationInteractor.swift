import YooKassaPaymentsApi

final class TokenizationInteractor {

    // MARK: - VIPER

    weak var output: TokenizationInteractorOutput?

    // MARK: - Init data

    private let paymentService: PaymentService
    private let authorizationService: AuthorizationService
    private let analyticsService: AnalyticsService
    private let analyticsProvider: AnalyticsProvider

    private let clientApplicationKey: String

    // MARK: - Init

    init(
        paymentService: PaymentService,
        authorizationService: AuthorizationService,
        analyticsService: AnalyticsService,
        analyticsProvider: AnalyticsProvider,
        clientApplicationKey: String
    ) {
        ThreatMetrixService.configure()

        self.paymentService = paymentService
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider

        self.clientApplicationKey = clientApplicationKey
    }
}

// MARK: - TokenizationInteractorInput

extension TokenizationInteractor: TokenizationInteractorInput {
    func tokenize(
        _ data: TokenizeData,
        paymentOption: PaymentOption,
        tmxSessionId: String?
    ) {
        if let tmxSessionId = tmxSessionId {
            tokenizeWithTMXSessionId(
                data,
                paymentOption: paymentOption,
                tmxSessionId: tmxSessionId
            )
        } else {
            ThreatMetrixService.profileApp { [weak self] result in
                guard let self = self,
                      let output = self.output else { return }

                switch result {
                case let .success(tmxSessionId):
                    self.tokenizeWithTMXSessionId(
                        data,
                        paymentOption: paymentOption,
                        tmxSessionId: tmxSessionId
                    )

                case let .failure(error):
                    let mappedError = mapError(error)
                    output.failTokenizeData(mappedError)
                }
            }
        }
    }

    private func tokenizeWithTMXSessionId(
        _ data: TokenizeData,
        paymentOption: PaymentOption,
        tmxSessionId: String
    ) {
        guard let output = output else { return }

        let completion: (Result<Tokens, Error>) -> Void = { result in
            switch result {
            case let .success(data):
                output.didTokenizeData(data)
            case let .failure(error):
                let mappedError = mapError(error)
                output.failTokenizeData(mappedError)
            }
        }

        let monetaryAmount = paymentOption.charge

        switch data {
        case let .bankCard(bankCard, confirmation, savePaymentMethod):
            self.paymentService.tokenizeBankCard(
                clientApplicationKey: self.clientApplicationKey,
                bankCard: bankCard,
                confirmation: confirmation,
                savePaymentMethod: savePaymentMethod,
                amount: monetaryAmount.plain,
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
                paymentMethodType: paymentOption.paymentMethodType.plain,
                amount: monetaryAmount.plain,
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
                paymentMethodType: paymentOption.paymentMethodType.plain,
                amount: monetaryAmount.plain,
                tmxSessionId: tmxSessionId,
                completion: completion
            )

        case let .applePay(paymentData, savePaymentMethod):
            self.paymentService.tokenizeApplePay(
                clientApplicationKey: self.clientApplicationKey,
                paymentData: paymentData,
                savePaymentMethod: savePaymentMethod,
                amount: monetaryAmount.plain,
                tmxSessionId: tmxSessionId,
                completion: completion
            )

        case let .sberbank(phoneNumber, confirmation, savePaymentMethod):
            self.paymentService.tokenizeSberbank(
                clientApplicationKey: self.clientApplicationKey,
                phoneNumber: phoneNumber,
                confirmation: confirmation,
                savePaymentMethod: savePaymentMethod,
                amount: monetaryAmount.plain,
                tmxSessionId: tmxSessionId,
                completion: completion
            )
        }
    }

    func getWalletDisplayName() -> String? {
        return authorizationService.getWalletDisplayName()
    }

    func loginInWallet(
        reusableToken: Bool,
        paymentOption: PaymentOption,
        tmxSessionId: String?
    ) {
        authorizationService.loginInWallet(
            merchantClientAuthorization: clientApplicationKey,
            amount: paymentOption.charge.plain,
            reusableToken: reusableToken,
            tmxSessionId: tmxSessionId
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case let .success(response):
                output.didLoginInWallet(response)
            case let .failure(error):
                let mappedError = mapError(error)
                output.failLoginInWallet(mappedError)
            }
        }
    }

    func resendSmsCode(
        authContextId: String,
        authType: AuthType
    ) {
        authorizationService.startNewAuthSession(
            merchantClientAuthorization: clientApplicationKey,
            contextId: authContextId,
            authType: authType
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case let .success(state):
                output.didResendSmsCode(state)
            case let .failure(error):
                output.failLoginInWallet(error)
            }
        }
    }

    func loginInWallet(
        authContextId: String,
        authType: AuthType,
        answer: String,
        processId: String
    ) {
        authorizationService.checkUserAnswer(
            merchantClientAuthorization: clientApplicationKey,
            authContextId: authContextId,
            authType: authType,
            answer: answer,
            processId: processId
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case let .success(response):
                output.didLoginInWallet(response)
            case let .failure(error):
                let mappedError = mapError(error)
                output.failLoginInWallet(mappedError)
            }

        }
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
