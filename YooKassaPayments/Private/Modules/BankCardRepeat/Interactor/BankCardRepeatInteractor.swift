import FunctionalSwift
import When
import YooKassaPaymentsApi

final class BankCardRepeatInteractor {

    // MARK: - VIPER

    weak var output: BankCardRepeatInteractorOutput?

    // MARK: - Initialization

    private let clientApplicationKey: String
    private let paymentService: PaymentService
    private let analyticsService: AnalyticsProcessing

    init(
        clientApplicationKey: String,
        paymentService: PaymentService,
        analyticsService: AnalyticsProcessing
    ) {
        ThreatMetrixService.configure()

        self.clientApplicationKey = clientApplicationKey
        self.paymentService = paymentService
        self.analyticsService = analyticsService
    }
}

// MARK: - BankCardRepeatInteractorInput

extension BankCardRepeatInteractor: BankCardRepeatInteractorInput {

    func fetchPaymentMethod(paymentMethodId: String) {
        paymentService.fetchPaymentMethod(
            clientApplicationKey: clientApplicationKey,
            paymentMethodId: paymentMethodId
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case .success(let data):
                output.didFetchPaymentMethod(data)
            case .failure(let error):
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
        guard let output = output else { return }

        let tmxSessionId = ThreatMetrixService.profileApp()
        tmxSessionId.done { [weak self] tmxSessionId in
            guard let self = self else { return }
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
                case .success(let data):
                    output.didTokenize(data)
                case .failure(let error):
                    let mappedError = mapError(error)
                    output.didFailTokenize(mappedError)
                }
            }
        }

        let tmxSessionIdWithError = tmxSessionId.recover(on: .global(), mapError)
        tmxSessionIdWithError.fail(output.didFailTokenize)
    }

    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
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

private func mapError<T>(_ error: Error) throws -> Promise<T> {
    switch error {
    case ThreatMetrixService.ProfileError.connectionFail:
        throw PaymentProcessingError.internetConnection
    default:
        throw error
    }
}
