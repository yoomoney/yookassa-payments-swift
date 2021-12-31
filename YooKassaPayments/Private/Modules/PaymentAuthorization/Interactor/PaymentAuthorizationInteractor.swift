import ThreatMetrixAdapter

final class PaymentAuthorizationInteractor {

    // MARK: - VIPER

    weak var output: PaymentAuthorizationInteractorOutput?

    // MARK: - Init data

    private let authorizationService: AuthorizationService
    private let analyticsService: AnalyticsTracking
    private let clientApplicationKey: String

    // MARK: - Init

    init(
        authorizationService: AuthorizationService,
        analyticsService: AnalyticsTracking,
        clientApplicationKey: String
    ) {
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.clientApplicationKey = clientApplicationKey
    }
}

// MARK: - PaymentAuthorizationInteractorInput

extension PaymentAuthorizationInteractor: PaymentAuthorizationInteractorInput {
    func resendCode(
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
                output.didResendCode(authTypeState: state)
            case let .failure(error):
                output.didFailResendCode(error)
            }
        }
    }

    func checkUserAnswer(
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
                output.didCheckUserAnswer(response)
            case let .failure(error):
                let mappedError = mapError(error)
                output.didFailCheckUserAnswer(mappedError)
            }
        }
    }

    func getWalletPhoneTitle() -> String? {
        return authorizationService.getWalletPhoneTitle()
    }

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }

    func analyticsAuthType() -> AnalyticsEvent.AuthType {
        authorizationService.analyticsAuthType()
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
