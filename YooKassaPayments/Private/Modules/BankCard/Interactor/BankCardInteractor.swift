final class BankCardInteractor {

    // MARK: - VIPER

    weak var output: BankCardInteractorOutput?

    // MARK: - Initialization

    private let paymentService: PaymentService
    private let analyticsService: AnalyticsService
    private let analyticsProvider: AnalyticsProvider
    private let clientApplicationKey: String
    private let amount: MonetaryAmount
    private let returnUrl: String

    init(
        paymentService: PaymentService,
        analyticsService: AnalyticsService,
        analyticsProvider: AnalyticsProvider,
        clientApplicationKey: String,
        amount: MonetaryAmount,
        returnUrl: String
    ) {
        self.paymentService = paymentService
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider
        self.clientApplicationKey = clientApplicationKey
        self.amount = amount
        self.returnUrl = returnUrl

        if !ThreatMetrixService.isConfigured {
            ThreatMetrixService.configure()
        }
    }
}

// MARK: - BankCardInteractorInput

extension BankCardInteractor: BankCardInteractorInput {
    func tokenizeBankCard(
        cardData: CardData,
        savePaymentMethod: Bool
    ) {
        ThreatMetrixService.profileApp { [weak self] result in
            guard let self = self,
                  let output = self.output else { return }

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
                    tmxSessionId: tmxSessionId
                ) { [weak self] result in
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

    func trackEvent(
        _ event: AnalyticsEvent
    ) {
        analyticsService.trackEvent(event)
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
    case ThreatMetrixService.ProfileError.connectionFail:
        return PaymentProcessingError.internetConnection
    case let error as NSError where error.domain == NSURLErrorDomain:
        return PaymentProcessingError.internetConnection
    default:
        return error
    }
}
