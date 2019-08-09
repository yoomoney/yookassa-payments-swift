import FunctionalSwift
import When
import YandexCheckoutPaymentsApi

final class BankCardRepeatInteractor {

    // MARK: - VIPER

    weak var output: BankCardRepeatInteractorOutput?

    // MARK: - Initialization

    private let clientApplicationKey: String
    private let paymentService: PaymentProcessing

    init(clientApplicationKey: String,
         paymentService: PaymentProcessing) {
        ThreatMetrixService.configure()

        self.clientApplicationKey = clientApplicationKey
        self.paymentService = paymentService
    }
}

// MARK: - BankCardRepeatInteractorInput

extension BankCardRepeatInteractor: BankCardRepeatInteractorInput {

    func fetchPaymentMethod(paymentMethodId: String) {
        guard let output = output else { return }

        let paymentMethod = paymentService.fetchPaymentMethod(
            clientApplicationKey: clientApplicationKey,
            paymentMethodId: paymentMethodId
        )
        paymentMethod.done(output.didFetchPaymentMethod)
        paymentMethod.fail(output.didFailFetchPaymentMethod)
    }

    func tokenize(
        amount: MonetaryAmount,
        confirmation: Confirmation,
        paymentMethodId: String,
        csc: String
    ) {
        guard let output = output else { return }

        let tmxSessionId = ThreatMetrixService.profileApp()
        tmxSessionId.done { [weak self] tmxSessionId in
            guard let self = self else { return }
            let response = self.paymentService.tokenizeRepeatBankCard(
                clientApplicationKey: self.clientApplicationKey,
                amount: amount,
                tmxSessionId: tmxSessionId,
                confirmation: confirmation,
                paymentMethodId: paymentMethodId,
                csc: csc
            )

            let responseWithError = response.recover(on: .global(), mapError)

            responseWithError.done(output.didTokenize)
            responseWithError.fail(output.didFailTokenize)
        }

        let tmxSessionIdWithError = tmxSessionId.recover(on: .global(), mapError)
        tmxSessionIdWithError.fail(output.didFailTokenize)
    }
}

// MARK: - Private global helpers

private func mapError<T>(_ error: Error) throws -> Promise<T> {
    switch error {
    case ThreatMetrixService.ProfileError.connectionFail:
        throw PaymentProcessingError.internetConnection
    default:
        throw error
    }
}
