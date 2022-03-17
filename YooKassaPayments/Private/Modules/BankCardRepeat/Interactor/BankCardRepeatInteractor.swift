import ThreatMetrixAdapter

final class BankCardRepeatInteractor {

    // MARK: - VIPER

    weak var output: BankCardRepeatInteractorOutput?

    // MARK: - Init data

    private let authService: AuthorizationService
    private let analyticsService: AnalyticsTracking
    private let paymentService: PaymentService
    private let threatMetrixService: ThreatMetrixService
    private let amountNumberFormatter: AmountNumberFormatter

    private let clientApplicationKey: String
    private let gatewayId: String?
    private let amount: Amount

    // MARK: - Init

    init(
        authService: AuthorizationService,
        analyticsService: AnalyticsTracking,
        paymentService: PaymentService,
        threatMetrixService: ThreatMetrixService,
        amountNumberFormatter: AmountNumberFormatter,
        clientApplicationKey: String,
        gatewayId: String?,
        amount: Amount
    ) {
        self.authService = authService
        self.analyticsService = analyticsService
        self.paymentService = paymentService
        self.threatMetrixService = threatMetrixService
        self.amountNumberFormatter = amountNumberFormatter

        self.clientApplicationKey = clientApplicationKey
        self.gatewayId = gatewayId
        self.amount = amount
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
        threatMetrixService.profileApp { [weak self] result in
            guard let self = self,
                  let output = self.output else { return }

            switch result {
            case let .success(tmxSessionId):
            self.paymentService.tokenizeRepeatBankCard(
                clientApplicationKey: self.clientApplicationKey,
                amount: amount,
                tmxSessionId: tmxSessionId.value,
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

    func fetchPaymentMethods() {
        paymentService.fetchPaymentOptions(
            clientApplicationKey: clientApplicationKey,
            authorizationToken: nil,
            gatewayId: gatewayId,
            amount: amountNumberFormatter.string(from: amount.value),
            currency: amount.currency.rawValue,
            getSavePaymentMethod: false,
            customerId: nil
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case let .success(data):
                output.didFetchPaymentMethods(data.options)
            case let .failure(error):
                output.didFetchPaymentMethods(error)
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

private func mapError(_ error: Error) -> Error {
    switch error {
    case ProfileError.connectionFail:
        return PaymentProcessingError.internetConnection
    default:
        return error
    }
}
