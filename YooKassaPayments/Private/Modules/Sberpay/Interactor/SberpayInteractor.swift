import ThreatMetrixAdapter

final class SberpayInteractor {

    // MARK: - VIPER

    weak var output: SberpayInteractorOutput?

    // MARK: - Init

    private let authService: AuthorizationService
    private let paymentService: PaymentService
    private let analyticsService: AnalyticsTracking
    private let threatMetrixService: ThreatMetrixService
    private let clientApplicationKey: String
    private let amount: MonetaryAmount
    private let returnUrl: String
    private let customerId: String?

    init(
        authService: AuthorizationService,
        paymentService: PaymentService,
        analyticsService: AnalyticsTracking,
        threatMetrixService: ThreatMetrixService,
        clientApplicationKey: String,
        amount: MonetaryAmount,
        returnUrl: String,
        customerId: String?
    ) {
        self.authService = authService
        self.paymentService = paymentService
        self.analyticsService = analyticsService
        self.threatMetrixService = threatMetrixService
        self.clientApplicationKey = clientApplicationKey
        self.amount = amount
        self.returnUrl = returnUrl
        self.customerId = customerId
    }
}

// MARK: - SberpayInteractorInput

extension SberpayInteractor: SberpayInteractorInput {
    func tokenizeSberpay(savePaymentMethod: Bool) {
        threatMetrixService.profileApp { [weak self] result in
            guard let self = self, let output = self.output else { return }

            switch result {
            case let .success(tmxSessionId):
                let confirmation = Confirmation(
                    type: .mobileApplication,
                    returnUrl: self.returnUrl
                )
                self.paymentService.tokenizeSberpay(
                    clientApplicationKey: self.clientApplicationKey,
                    confirmation: confirmation,
                    savePaymentMethod: savePaymentMethod,
                    amount: self.amount,
                    tmxSessionId: tmxSessionId.value,
                    customerId: self.customerId
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

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }

    func analyticsAuthType() -> AnalyticsEvent.AuthType {
        authService.analyticsAuthType()
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
