import ThreatMetrixAdapter

final class LinkedCardInteractor {

    // MARK: - VIPER

    weak var output: LinkedCardInteractorOutput?
    
    // MARK: - Init data
    
    private let authorizationService: AuthorizationService
    private let analyticsService: AnalyticsService
    private let analyticsProvider: AnalyticsProvider
    private let paymentService: PaymentService
    private let threatMetrixService: ThreatMetrixService
    
    private let clientApplicationKey: String

    // MARK: - Init

    init(
        authorizationService: AuthorizationService,
        analyticsService: AnalyticsService,
        analyticsProvider: AnalyticsProvider,
        paymentService: PaymentService,
        threatMetrixService: ThreatMetrixService,
        clientApplicationKey: String
    ) {
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider
        self.paymentService = paymentService
        self.threatMetrixService = threatMetrixService
        
        self.clientApplicationKey = clientApplicationKey
    }
}

// MARK: - LinkedCardInteractorInput

extension LinkedCardInteractor: LinkedCardInteractorInput {
    func loginInWallet(
        amount: MonetaryAmount,
        reusableToken: Bool,
        tmxSessionId: String?
    ) {
        authorizationService.loginInWallet(
            merchantClientAuthorization: clientApplicationKey,
            amount: amount,
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
    
    func tokenize(
        id: String,
        csc: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount,
        tmxSessionId: String?
    ) {
        if let tmxSessionId = tmxSessionId {
            tokenizeWithTMXSessionId(
                id: id,
                csc: csc,
                confirmation: confirmation,
                savePaymentMethod: savePaymentMethod,
                paymentMethodType: paymentMethodType,
                amount: amount,
                tmxSessionId: tmxSessionId
            )
        } else {
            threatMetrixService.profileApp { [weak self] result in
                guard let self = self,
                      let output = self.output else { return }

                switch result {
                case let .success(tmxSessionId):
                    self.tokenizeWithTMXSessionId(
                        id: id,
                        csc: csc,
                        confirmation: confirmation,
                        savePaymentMethod: savePaymentMethod,
                        paymentMethodType: paymentMethodType,
                        amount: amount,
                        tmxSessionId: tmxSessionId
                    )

                case let .failure(error):
                    let mappedError = mapError(error)
                    output.failTokenizeData(mappedError)
                }
            }
        }
    }
    
    func hasReusableWalletToken() -> Bool {
        return authorizationService.hasReusableWalletToken()
    }
    
    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }
    
    func makeTypeAnalyticsParameters() -> (
        authType: AnalyticsEvent.AuthType,
        tokenType: AnalyticsEvent.AuthTokenType?
    ) {
        return analyticsProvider.makeTypeAnalyticsParameters()
    }
    
    private func tokenizeWithTMXSessionId(
        id: String,
        csc: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount,
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

        guard let walletToken = authorizationService.getWalletToken() else {
            assertionFailure("You must be authorized in wallet")
            return
        }

        paymentService.tokenizeLinkedBankCard(
            clientApplicationKey: clientApplicationKey,
            walletAuthorization: walletToken,
            cardId: id,
            csc: csc,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod,
            paymentMethodType: paymentMethodType,
            amount: amount,
            tmxSessionId: tmxSessionId,
            completion: completion
        )
    }
}


private func mapError(_ error: Error) -> Error {
    switch error {
    case ProfileError.connectionFail:
        return PaymentProcessingError.internetConnection
    case let error as NSError where error.domain == NSURLErrorDomain:
        return PaymentProcessingError.internetConnection
    default:
        return error
    }
}
