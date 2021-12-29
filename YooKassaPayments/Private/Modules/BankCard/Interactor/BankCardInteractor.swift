import ThreatMetrixAdapter

final class BankCardInteractor {

    // MARK: - VIPER

    weak var output: BankCardInteractorOutput?

    // MARK: - Initialization

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

// MARK: - BankCardInteractorInput

extension BankCardInteractor: BankCardInteractorInput {
    func tokenizeInstrument(id: String, csc: String?, savePaymentMethod: Bool) {
        threatMetrixService.profileApp { [weak self] result in
            guard let self = self, let output = self.output else { return }
            switch result {
            case .success(let tmxId):
                self.paymentService.tokenizeCardInstrument(
                    clientApplicationKey: self.clientApplicationKey,
                    amount: self.amount,
                    tmxSessionId: tmxId.value,
                    confirmation: makeConfirmation(returnUrl: self.returnUrl),
                    savePaymentMethod: savePaymentMethod,
                    instrumentId: id,
                    csc: csc
                ) { tokenizeResult in
                    switch tokenizeResult {
                    case .success(let tokens):
                        output.didTokenize(tokens)
                    case .failure(let error):
                        let mappedError = mapError(error)
                        output.didFailTokenize(mappedError)
                    }
                }
            case .failure(let error):
                let mappedError = mapError(error)
                output.didFailTokenize(mappedError)
            }
        }
    }
    func tokenizeBankCard(cardData: CardData, savePaymentMethod: Bool, savePaymentInstrument: Bool?) {
        threatMetrixService.profileApp { [weak self] result in
            guard
                let self = self,
                let output = self.output
            else { return }

            switch result {
            case let .success(tmxSessionId):
                guard let bankCard = makeBankCard(cardData) else {
                    return
                }
                let confirmation = makeConfirmation(
                    returnUrl: self.returnUrl
                )
                self.paymentService.tokenizeBankCard(
                    clientApplicationKey: self.clientApplicationKey,
                    bankCard: bankCard,
                    confirmation: confirmation,
                    savePaymentMethod: savePaymentMethod,
                    amount: self.amount,
                    tmxSessionId: tmxSessionId.value,
                    customerId: self.customerId,
                    savePaymentInstrument: savePaymentInstrument
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

private func makeBankCard(
    _ cardData: CardData
) -> BankCard? {
    guard let number = cardData.pan,
          let expiryDateComponents = cardData.expiryDate,
          let expiryYear = expiryDateComponents.year.flatMap(String.init),
          let expiryMonth = expiryDateComponents.month.flatMap(String.init),
          let csc = cardData.csc else {
        return nil
    }
    let bankCard = BankCard(
        number: number,
        expiryYear: expiryYear,
        expiryMonth: makeCorrectExpiryMonth(expiryMonth),
        csc: csc,
        cardholder: nil
    )
    return bankCard
}

private func makeCorrectExpiryMonth(
    _ month: String
) -> String {
    month.count > 1 ? month : "0" + month
}

private func makeConfirmation(
    returnUrl: String
) -> Confirmation {
    Confirmation(type: .redirect, returnUrl: returnUrl)
}

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
