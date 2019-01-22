import FunctionalSwift
import When
import YandexCheckoutPaymentsApi

final class MockPaymentService: PaymentProcessing {

    // MARK: - Initial parameters
    private let paymentMethodHandler: PaymentMethodHandler
    private let testModeSettings: TestModeSettings
    private let authorizationMediator: AuthorizationProcessing

    // MARK: - Creating object
    init(paymentMethodHandler: PaymentMethodHandler,
         testModeSettings: TestModeSettings,
         authorizationMediator: AuthorizationProcessing) {
        self.paymentMethodHandler = paymentMethodHandler
        self.testModeSettings = testModeSettings
        self.authorizationMediator = authorizationMediator
    }

    // MARK: - PaymentProcessing

    func fetchPaymentOptions(clientApplicationKey: String,
                             passportToken: String?,
                             gatewayId: String?,
                             amount: String?,
                             currency: String?) -> Promise<[PaymentOption]> {
        let timeout = makeTimeoutPromise()

        let authorized = authorizationMediator.getYandexToken() != nil
        let response = makePaymentOptions(testModeSettings,
                                          handler: paymentMethodHandler,
                                          authorized: authorized)

        let handleResponse: ([PaymentOption]) throws -> [PaymentOption] = {
            if $0.isEmpty {
                throw PaymentProcessingError.emptyList
            } else {
                return $0
            }
        }

        let promise = response <^ timeout
        return handleResponse <^> promise
    }

    func tokenizeBankCard(clientApplicationKey: String,
                          bankCard: BankCard,
                          confirmation: Confirmation,
                          amount: MonetaryAmount?,
                          tmxSessionId: String) -> Promise<Tokens> {
        return makeTokensPromise()
    }

    func tokenizeWallet(clientApplicationKey: String,
                        yamoneyToken: String,
                        confirmation: Confirmation,
                        amount: MonetaryAmount?,
                        tmxSessionId: String) -> Promise<Tokens> {
        return makeTokensPromise()
    }

    func tokenizeLinkedBankCard(clientApplicationKey: String,
                                yamoneyToken: String,
                                cardId: String,
                                csc: String,
                                confirmation: Confirmation,
                                amount: MonetaryAmount?,
                                tmxSessionId: String) -> Promise<Tokens> {
        return makeTokensPromise()
    }

    func tokenizeSberbank(clientApplicationKey: String,
                          phoneNumber: String,
                          confirmation: Confirmation,
                          amount: MonetaryAmount?,
                          tmxSessionId: String) -> Promise<Tokens> {
        return makeTokensPromise()
    }

    func tokenizeApplePay(clientApplicationKey: String,
                          paymentData: String,
                          amount: MonetaryAmount?,
                          tmxSessionId: String) -> Promise<Tokens> {
        return makeTokensPromise()
    }

    private func makeTokensPromise() -> Promise<Tokens> {
        let timeout = makeTimeoutPromise()

        let tokens = mockTokens <^ timeout

        let enablePaymentError = testModeSettings.enablePaymentError
        let handleResponse: (Tokens) throws -> Tokens = {
            if enablePaymentError {
                throw mockError
            } else {
                return $0
            }
        }

        return handleResponse <^> tokens
    }
}

// MARK: - Promise helper

private let timeout: Double = 2

private func makeTimeoutPromise() -> Promise<()> {
    let promise: Promise<()> = Promise()
    DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
        promise.resolve(())
    }
    return promise
}

// MARK: - Data for Error

private struct MockError: Error { }

private let mockError = MockError()

// MARK: - Mock responses

private let mockTokens = Tokens(paymentToken: "mock_token")

private func makePaymentOptions(_ settings: TestModeSettings,
                                handler: PaymentMethodHandler, authorized: Bool) -> [PaymentOption] {
    let linkedCards = authorized ?
        Array(repeating: makeLinkedCard(settings.charge), count: settings.cardsCount) : []

    let paymentOptions = makeDefaultPaymentOptions(settings.charge, authorized: authorized) + linkedCards.map { $0 }
    let filteredPaymentOptions = handler.filterPaymentMethods(paymentOptions)
    return filteredPaymentOptions
}

private func makeLinkedCard(_ charge: Amount) -> PaymentInstrumentYandexMoneyLinkedBankCard {
    return PaymentInstrumentYandexMoneyLinkedBankCard(paymentMethodType: .yandexMoney,
                                                      confirmationTypes: nil,
                                                      charge: MonetaryAmountFactory.makePaymentsMonetaryAmount(charge),
                                                      instrumentType: .linkedBankCard,
                                                      cardId: "123456789",
                                                      cardName: "Привязанная карта",
                                                      cardMask: "518901******0446",
                                                      cardType: .masterCard,
                                                      identificationRequirement: .simplified)
}

private func makeDefaultPaymentOptions(_ charge: Amount, authorized: Bool) -> [PaymentOption] {
    var response: [PaymentOption] = []
    let charge = MonetaryAmountFactory.makePaymentsMonetaryAmount(charge)

    if authorized {

        response += [
            PaymentInstrumentYandexMoneyWallet(paymentMethodType: .yandexMoney,
                                               confirmationTypes: [],
                                               charge: charge,
                                               instrumentType: .wallet,
                                               accountId: "2736482364872",
                                               balance: MonetaryAmount(value: 40_000, currency: .rub),
                                               identificationRequirement: .simplified),
        ]

    } else {

        response += [
            PaymentOption(paymentMethodType: .yandexMoney,
                          confirmationTypes: [],
                          charge: charge,
                          identificationRequirement: nil),
        ]
    }

    response += [
        PaymentOption(paymentMethodType: .sberbank,
                      confirmationTypes: [],
                      charge: charge,
                      identificationRequirement: nil),
        PaymentOption(paymentMethodType: .bankCard,
                      confirmationTypes: [],
                      charge: charge,
                      identificationRequirement: nil),
        PaymentOption(paymentMethodType: .applePay,
                      confirmationTypes: [],
                      charge: charge,
                      identificationRequirement: nil),
    ]

    return response
}
