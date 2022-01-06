import ThreatMetrixAdapter

final class SberbankInteractor {

    // MARK: - VIPER

    weak var output: SberbankInteractorOutput?

    // MARK: - Init

    private let authService: AuthorizationService
    private let paymentService: PaymentService
    private let analyticsService: AnalyticsTracking
    private let threatMetrixService: ThreatMetrixService
    private let clientApplicationKey: String
    private let amount: MonetaryAmount
    private let customerId: String?

    init(
        authService: AuthorizationService,
        paymentService: PaymentService,
        analyticsService: AnalyticsTracking,
        threatMetrixService: ThreatMetrixService,
        clientApplicationKey: String,
        amount: MonetaryAmount,
        customerId: String?
    ) {
        self.authService = authService
        self.paymentService = paymentService
        self.analyticsService = analyticsService
        self.threatMetrixService = threatMetrixService
        self.clientApplicationKey = clientApplicationKey
        self.amount = amount
        self.customerId = customerId
    }
}

// MARK: - SberbankInteractorInput

extension SberbankInteractor: SberbankInteractorInput {
    func tokenizeSberbank(phoneNumber: String, savePaymentMethod: Bool) {
        threatMetrixService.profileApp { [weak self] result in
            guard let self = self, let output = self.output else { return }

            switch result {
            case let .success(tmxSessionId):
                let confirmation = Confirmation(
                    type: .external,
                    returnUrl: nil
                )
                self.paymentService.tokenizeSberbank(
                    clientApplicationKey: self.clientApplicationKey,
                    phoneNumber: phoneNumber,
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

    func analyticsAuthType() -> AnalyticsEvent.AuthType {
        authService.analyticsAuthType()
    }

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
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
