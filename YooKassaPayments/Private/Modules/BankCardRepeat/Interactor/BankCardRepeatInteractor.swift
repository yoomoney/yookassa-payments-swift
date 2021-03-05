final class BankCardRepeatInteractor {

    // MARK: - VIPER

    weak var output: BankCardRepeatInteractorOutput?

    // MARK: - Init data

    private let analyticsService: AnalyticsService
    private let analyticsProvider: AnalyticsProvider
    private let paymentService: PaymentService
    
    private let clientApplicationKey: String

    // MARK: - Init

    init(
        analyticsService: AnalyticsService,
        analyticsProvider: AnalyticsProvider,
        paymentService: PaymentService,
        clientApplicationKey: String
    ) {
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider
        self.paymentService = paymentService
        
        self.clientApplicationKey = clientApplicationKey

        if !ThreatMetrixService.isConfigured {
            ThreatMetrixService.configure()
        }
    }
}

// MARK: - BankCardRepeatInteractorInput

extension BankCardRepeatInteractor: BankCardRepeatInteractorInput {
    func fetchPaymentMethod(
        paymentMethodId: String
    ) {
        paymentService.fetchPaymentMethod(
            clientApplicationKey: clientApplicationKey,
            paymentMethodId: paymentMethodId
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case let .success(data):
                output.didFetchPaymentMethod(data)
            case let .failure(error):
                output.didFailFetchPaymentMethod(error)
            }
        }
    }

    func tokenize(
        amount: MonetaryAmount,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodId: String,
        csc: String
    ) {
        ThreatMetrixService.profileApp { [weak self] result in
            guard let self = self,
                  let output = self.output else { return }

            switch result {
            case let .success(tmxSessionId):
            self.paymentService.tokenizeRepeatBankCard(
                clientApplicationKey: self.clientApplicationKey,
                amount: amount,
                tmxSessionId: tmxSessionId,
                confirmation: confirmation,
                savePaymentMethod: savePaymentMethod,
                paymentMethodId: paymentMethodId,
                csc: csc
            ) { result in
                switch result {
                case let .success(data):
                    output.didTokenize(data)
                case let .failure(error):
                    let mappedError = mapError(error)
                    output.didFailTokenize(mappedError)
                }
            }

            case let .failure(error):
                output.didFailTokenize(mapError(error))
                break
            }
        }
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
}

// MARK: - Private global helpers

private func mapError(_ error: Error) -> Error {
    switch error {
    case ThreatMetrixService.ProfileError.connectionFail:
        return PaymentProcessingError.internetConnection
    default:
        return error
    }
}
