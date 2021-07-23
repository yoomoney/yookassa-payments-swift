import ThreatMetrixAdapter

final class SberpayInteractor {

    // MARK: - VIPER

    weak var output: SberpayInteractorOutput?

    // MARK: - Init

    private let paymentService: PaymentService
    private let analyticsProvider: AnalyticsProvider
    private let analyticsService: AnalyticsService
    private let threatMetrixService: ThreatMetrixService
    private let clientApplicationKey: String
    private let amount: MonetaryAmount
    private let returnUrl: String

    init(
        paymentService: PaymentService,
        analyticsProvider: AnalyticsProvider,
        analyticsService: AnalyticsService,
        threatMetrixService: ThreatMetrixService,
        clientApplicationKey: String,
        amount: MonetaryAmount,
        returnUrl: String
    ) {
        self.paymentService = paymentService
        self.analyticsProvider = analyticsProvider
        self.analyticsService = analyticsService
        self.threatMetrixService = threatMetrixService
        self.clientApplicationKey = clientApplicationKey
        self.amount = amount
        self.returnUrl = returnUrl
    }
}

// MARK: - SberpayInteractorInput

extension SberpayInteractor: SberpayInteractorInput {
    func tokenizeSberpay() {
        threatMetrixService.profileApp { [weak self] result in
            guard let self = self,
                  let output = self.output else { return }

            switch result {
            case let .success(tmxSessionId):
                let confirmation = Confirmation(
                    type: .mobileApplication,
                    returnUrl: self.returnUrl
                )
                self.paymentService.tokenizeSberpay(
                    clientApplicationKey: self.clientApplicationKey,
                    confirmation: confirmation,
                    savePaymentMethod: false,
                    amount: self.amount,
                    tmxSessionId: tmxSessionId.value
                ) { result in
                    switch result {
                    case .success(let data):
                        output.didTokenize(data)
                    case .failure(let error):
                        let mappedError = mapError(error)
                        output.didFailTokenize(mappedError)
                    }
                }

            case let .failure(error):
                let mappedError = mapError(error)
                output.didFailTokenize(mappedError)
            }
        }
    }

    func makeTypeAnalyticsParameters() -> (
        authType: AnalyticsEvent.AuthType,
        tokenType: AnalyticsEvent.AuthTokenType?
    ) {
        analyticsProvider.makeTypeAnalyticsParameters()
    }

    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }
}

// MARK: - Private global helpers

private func mapError(
    _ error: Error
) -> Error {
    switch error {
    case ProfileError.connectionFail:
        return PaymentProcessingError.internetConnection
    case let error as NSError where error.domain == NSURLErrorDomain:
        return PaymentProcessingError.internetConnection
    default:
        return error
    }
}
