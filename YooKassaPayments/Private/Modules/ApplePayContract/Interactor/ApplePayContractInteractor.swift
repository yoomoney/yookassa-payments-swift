import ThreatMetrixAdapter

final class ApplePayContractInteractor {
    
    // MARK: - VIPER
    
    weak var output: ApplePayContractInteractorOutput?
    
    // MARK: - Init data
    
    private let paymentService: PaymentService
    private let analyticsService: AnalyticsService
    private let analyticsProvider: AnalyticsProvider
    private let threatMetrixService: ThreatMetrixService
    
    private let clientApplicationKey: String
    
    // MARK: - Init
    
    init(
        paymentService: PaymentService,
        analyticsService: AnalyticsService,
        analyticsProvider: AnalyticsProvider,
        threatMetrixService: ThreatMetrixService,
        clientApplicationKey: String
    ) {
        self.paymentService = paymentService
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider
        self.threatMetrixService = threatMetrixService

        self.clientApplicationKey = clientApplicationKey
    }
}

// MARK: - ApplePayContractInteractorInput

extension ApplePayContractInteractor: ApplePayContractInteractorInput {
    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }

    func makeTypeAnalyticsParameters() -> (authType: AnalyticsEvent.AuthType,
                                           tokenType: AnalyticsEvent.AuthTokenType?) {
        return analyticsProvider.makeTypeAnalyticsParameters()
    }
    
    func tokenize(
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount
    ) {
        threatMetrixService.profileApp { [weak self] result in
            guard let self = self,
                  let output = self.output else { return }

            switch result {
            case let .success(tmxSessionId):
                self.tokenizeApplePayWithTMXSessionId(
                    paymentData: paymentData,
                    savePaymentMethod: savePaymentMethod,
                    amount: amount,
                    tmxSessionId: tmxSessionId
                )

            case let .failure(error):
                let mappedError = mapError(error)
                output.failTokenize(mappedError)
            }
        }
    }
    
    private func tokenizeApplePayWithTMXSessionId(
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount,
        tmxSessionId: String
    ) {
        guard let output = output else { return }

        let completion: (Result<Tokens, Error>) -> Void = { result in
            switch result {
            case let .success(data):
                output.didTokenize(data)
            case let .failure(error):
                let mappedError = mapError(error)
                output.failTokenize(mappedError)
            }
        }

        paymentService.tokenizeApplePay(
            clientApplicationKey: clientApplicationKey,
            paymentData: paymentData,
            savePaymentMethod: savePaymentMethod,
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
