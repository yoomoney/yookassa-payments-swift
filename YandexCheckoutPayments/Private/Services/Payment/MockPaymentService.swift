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

    func fetchPaymentOptions(
        clientApplicationKey: String,
        passportToken: String?,
        gatewayId: String?,
        amount: String?,
        currency: String?,
        getSavePaymentMethod: Bool?
    ) -> Promise<[PaymentOption]> {
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

    func fetchPaymentMethod(
        clientApplicationKey: String,
        paymentMethodId: String
    ) -> Promise<YandexCheckoutPaymentsApi.PaymentMethod> {
        let timeout = makeTimeoutPromise()
        let error = PaymentsApiError(
            id: "id_value",
            type: .error,
            description: "description",
            parameter: "parameter",
            retryAfter: nil,
            errorCode: .invalidRequest
        )

        let errorHandler: (
            YandexCheckoutPaymentsApi.PaymentMethod
            ) throws -> YandexCheckoutPaymentsApi.PaymentMethod = {
            _ in
            throw error
        }

        let response = YandexCheckoutPaymentsApi.PaymentMethod(
            type: .bankCard,
            id: "id_value",
            saved: false,
            title: "title_value",
            cscRequired: true,
            card: .some(.init(
                first6: "123456",
                last4: "0987",
                expiryYear: "2020",
                expiryMonth: "11",
                cardType: .masterCard
            ))
        )

        let promise = timeout.then { _ in response }
        return promise
//        let promiseWithError = errorHandler <^> promise
//        return promiseWithError
    }

        func tokenizeBankCard(
        clientApplicationKey: String,
        bankCard: BankCard,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens> {
        return makeTokensPromise()
    }

    func tokenizeWallet(
        clientApplicationKey: String,
        yamoneyToken: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens> {
        return makeTokensPromise()
    }

    func tokenizeLinkedBankCard(
        clientApplicationKey: String,
        yamoneyToken: String,
        cardId: String,
        csc: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens> {
        return makeTokensPromise()
    }

    func tokenizeSberbank(
        clientApplicationKey: String,
        phoneNumber: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens> {
        return makeTokensPromise()
    }

    func tokenizeApplePay(
        clientApplicationKey: String,
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens> {
        return makeTokensPromise()
    }

    func tokenizeRepeatBankCard(
        clientApplicationKey: String,
        amount: MonetaryAmount,
        tmxSessionId: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodId: String,
        csc: String
    ) -> Promise<Tokens> {
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

private struct MockError: Error {
}

private let mockError = MockError()

// MARK: - Mock responses

private let mockTokens = Tokens(paymentToken: "mock_token")

private func makePaymentOptions(
    _ settings: TestModeSettings,
    handler: PaymentMethodHandler, authorized: Bool
) -> [PaymentOption] {

    let service = Service(charge: MonetaryAmount(value: 3.14, currency: settings.charge.currency.rawValue))
    let fee = Fee(service: service, counterparty: nil)

    let charge = makeCharge(charge: settings.charge, fee: fee)

    let linkedCards = authorized
        ? makeLinkedCards(count: settings.cardsCount, charge: charge, fee: fee)
        : []

    let paymentOptions = makeDefaultPaymentOptions(
        charge,
        fee: fee,
        authorized: authorized
    ) + linkedCards.map { $0 }

    let filteredPaymentOptions = handler.filterPaymentMethods(paymentOptions)

    return filteredPaymentOptions
}

private func makeCharge(
    charge: Amount, fee: Fee?
) -> Amount {
    guard let fee = fee, let service = fee.service else { return charge }
    return Amount(value: charge.value + service.charge.value, currency: charge.currency)
}

private func makeLinkedCards(
    count: Int,
    charge: Amount,
    fee: Fee?
) -> [PaymentInstrumentYandexMoneyLinkedBankCard] {
    return (0..<count).map { _ in makeLinkedCard(charge: charge, fee: fee) }
}

private func makeLinkedCard(
    charge: Amount, fee: Fee?
) -> PaymentInstrumentYandexMoneyLinkedBankCard {
    return PaymentInstrumentYandexMoneyLinkedBankCard(
        paymentMethodType: .yandexMoney,
        confirmationTypes: nil,
        charge: MonetaryAmountFactory.makePaymentsMonetaryAmount(charge),
        instrumentType: .linkedBankCard,
        cardId: "123456789",
        cardName: nil,
        cardMask: makeRandomCardMask(),
        cardType: .masterCard,
        identificationRequirement: .simplified,
        fee: fee,
        savePaymentMethod: .allowed
    )
}

private func makeRandomCardMask() -> String {
    let firstPart = Int.random(in: 100000..<1000000)
    let secondPart = Int.random(in: 1000..<10000)
    return "\(firstPart)******\(secondPart)"
}

private func makeDefaultPaymentOptions(
    _ charge: Amount, fee: Fee?, authorized: Bool
) -> [PaymentOption] {
    var response: [PaymentOption] = []
    let charge = MonetaryAmountFactory.makePaymentsMonetaryAmount(charge)

    if authorized {

        response += [
            PaymentInstrumentYandexMoneyWallet(
                paymentMethodType: .yandexMoney,
                confirmationTypes: [],
                charge: charge,
                instrumentType: .wallet,
                accountId: "2736482364872",
                balance: MonetaryAmount(value: 40_000, currency: charge.currency),
                identificationRequirement: .simplified,
                fee: fee,
                savePaymentMethod: .allowed
            ),
        ]

    } else {

        response += [
            PaymentOption(
                paymentMethodType: .yandexMoney,
                confirmationTypes: [],
                charge: charge,
                identificationRequirement: nil,
                fee: fee,
                savePaymentMethod: .allowed
            ),
        ]
    }

    response += [
        PaymentOption(
            paymentMethodType: .sberbank,
            confirmationTypes: [],
            charge: charge,
            identificationRequirement: nil,
            fee: fee,
            savePaymentMethod: .forbidden
        ),
        PaymentOption(
            paymentMethodType: .bankCard,
            confirmationTypes: [],
            charge: charge,
            identificationRequirement: nil,
            fee: fee,
            savePaymentMethod: .allowed
        ),
        PaymentOption(
            paymentMethodType: .applePay,
            confirmationTypes: [],
            charge: charge,
            identificationRequirement: nil,
            fee: fee,
            savePaymentMethod: .forbidden
        ),
    ]

    return response
}
