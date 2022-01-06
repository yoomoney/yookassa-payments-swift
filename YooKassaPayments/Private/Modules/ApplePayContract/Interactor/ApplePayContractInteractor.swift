import ThreatMetrixAdapter

final class ApplePayContractInteractor {

    // MARK: - VIPER

    weak var output: ApplePayContractInteractorOutput?

    // MARK: - Init data

    private let paymentService: PaymentService
    private let analyticsService: AnalyticsTracking
    private let threatMetrixService: ThreatMetrixService
    private let authorizationService: AuthorizationService

    private let clientApplicationKey: String
    private let customerId: String?

    // MARK: - Init

    init(
        paymentService: PaymentService,
        analyticsService: AnalyticsTracking,
        authorizationService: AuthorizationService,
        threatMetrixService: ThreatMetrixService,
        clientApplicationKey: String,
        customerId: String?
    ) {
        self.paymentService = paymentService
        self.analyticsService = analyticsService
        self.authorizationService = authorizationService
        self.threatMetrixService = threatMetrixService

        self.clientApplicationKey = clientApplicationKey
        self.customerId = customerId
    }
}

// MARK: - ApplePayContractInteractorInput

extension ApplePayContractInteractor: ApplePayContractInteractorInput {
    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }

    func analyticsAuthType() -> AnalyticsEvent.AuthType {
        authorizationService.analyticsAuthType()
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
                    tmxSessionId: tmxSessionId.value
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
            customerId: customerId,
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
