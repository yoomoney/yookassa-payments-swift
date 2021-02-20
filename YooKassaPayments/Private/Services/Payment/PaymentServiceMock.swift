import YooKassaPaymentsApi

final class PaymentServiceMock {

    // MARK: - Init data

    private let paymentMethodHandlerService: PaymentMethodHandlerService
    private let testModeSettings: TestModeSettings
    private let keyValueStoring: KeyValueStoring

    // MARK: - Init

    init(
        paymentMethodHandlerService: PaymentMethodHandlerService,
        testModeSettings: TestModeSettings,
        keyValueStoring: KeyValueStoring
    ) {
        self.paymentMethodHandlerService = paymentMethodHandlerService
        self.testModeSettings = testModeSettings
        self.keyValueStoring = keyValueStoring
    }
}

// MARK: - PaymentService

extension PaymentServiceMock: PaymentService {
    func fetchPaymentOptions(
        clientApplicationKey: String,
        authorizationToken: String?,
        gatewayId: String?,
        amount: String?,
        currency: String?,
        getSavePaymentMethod: Bool?,
        completion: @escaping (Result<[PaymentOption], Error>) -> Void
    ) {
        let authorized = keyValueStoring.getString(
            for: KeyValueStoringKeys.moneyCenterAuthToken
        ) != nil
        let items = makePaymentOptions(
            testModeSettings,
            handler: paymentMethodHandlerService,
            authorized: authorized
        )

        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
            if items.isEmpty {
                completion(.failure(PaymentProcessingError.emptyList))
            } else {
                completion(.success(items))
            }
        }
    }

    func fetchPaymentMethod(
        clientApplicationKey: String,
        paymentMethodId: String,
        completion: @escaping (Result<PaymentMethod, Error>) -> Void
    ) {
//        let error = PaymentsApiError(
//            id: "id_value",
//            type: .error,
//            description: "description",
//            parameter: "parameter",
//            retryAfter: nil,
//            errorCode: .invalidRequest
//        )

        let response = PaymentMethod(
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

        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
//            completion(.failure(error))
            completion(.success(response))
        }
    }

    func tokenizeBankCard(
        clientApplicationKey: String,
        bankCard: BankCard,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        completion: @escaping (Result<Tokens, Error>) -> Void
    ) {
        makeTokensPromise(completion: completion)
    }

    func tokenizeWallet(
        clientApplicationKey: String,
        walletAuthorization: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        completion: @escaping (Result<Tokens, Error>) -> Void
    ) {
        makeTokensPromise(completion: completion)
    }

    func tokenizeLinkedBankCard(
        clientApplicationKey: String,
        walletAuthorization: String,
        cardId: String,
        csc: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        completion: @escaping (Result<Tokens, Error>) -> Void
    ) {
        makeTokensPromise(completion: completion)
    }

    func tokenizeSberbank(
        clientApplicationKey: String,
        phoneNumber: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        completion: @escaping (Result<Tokens, Error>) -> Void
    ) {
        makeTokensPromise(completion: completion)
    }

    func tokenizeApplePay(
        clientApplicationKey: String,
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        completion: @escaping (Result<Tokens, Error>) -> Void
    ) {
        makeTokensPromise(completion: completion)
    }

    func tokenizeRepeatBankCard(
        clientApplicationKey: String,
        amount: MonetaryAmount,
        tmxSessionId: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodId: String,
        csc: String,
        completion: @escaping (Result<Tokens, Error>) -> Void
    ) {
        makeTokensPromise(completion: completion)
    }

    private func makeTokensPromise(
        completion: @escaping (Result<Tokens, Error>) -> Void
    ) {
        DispatchQueue.global().asyncAfter(deadline: .now() + timeout) { [weak self] in
            guard let self = self else { return }
            if self.testModeSettings.enablePaymentError {
                completion(.failure(mockError))
            } else {
                completion(.success(mockTokens))
            }
        }
    }
}

// MARK: - Promise helper

private let timeout: Double = 1

// MARK: - Data for Error

private struct MockError: Error { }

private let mockError = MockError()

// MARK: - Mock responses

private let mockTokens = Tokens(paymentToken: "mock_token")

private func makePaymentOptions(
    _ settings: TestModeSettings,
    handler: PaymentMethodHandlerService,
    authorized: Bool
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
) -> [PaymentInstrumentYooMoneyLinkedBankCard] {
    return (0..<count).map { _ in makeLinkedCard(charge: charge, fee: fee) }
}

private func makeLinkedCard(
    charge: Amount,
    fee: Fee?
) -> PaymentInstrumentYooMoneyLinkedBankCard {
    return PaymentInstrumentYooMoneyLinkedBankCard(
        paymentMethodType: .yooMoney,
        confirmationTypes: nil,
        charge: MonetaryAmountFactory.makePaymentsMonetaryAmount(charge),
        instrumentType: .linkedBankCard,
        cardId: "123456789",
        cardName: nil,
        cardMask: makeRandomCardMask(),
        cardType: .masterCard,
        identificationRequirement: .simplified,
        fee: fee?.paymentsModel,
        savePaymentMethod: .allowed
    )
}

private func makeRandomCardMask() -> String {
    let firstPart = Int.random(in: 100000..<1000000)
    let secondPart = Int.random(in: 1000..<10000)
    return "\(firstPart)******\(secondPart)"
}

private func makeDefaultPaymentOptions(
    _ charge: Amount,
    fee: Fee?,
    authorized: Bool
) -> [PaymentOption] {
    var response: [PaymentOption] = []
    let charge = MonetaryAmountFactory.makePaymentsMonetaryAmount(charge)

    if authorized {

        response += [
            PaymentInstrumentYooMoneyWallet(
                paymentMethodType: .yooMoney,
                confirmationTypes: [],
                charge: charge,
                instrumentType: .wallet,
                accountId: "2736482364872",
                balance: YooKassaPaymentsApi.MonetaryAmount(
                    value: 40_000,
                    currency: charge.currency
                ),
                identificationRequirement: .simplified,
                fee: fee?.paymentsModel,
                savePaymentMethod: .allowed
            ),
        ]

    } else {

        response += [
            PaymentOption(
                paymentMethodType: .yooMoney,
                confirmationTypes: [],
                charge: charge,
                identificationRequirement: nil,
                fee: fee?.paymentsModel,
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
            fee: fee?.paymentsModel,
            savePaymentMethod: .forbidden
        ),
        PaymentOption(
            paymentMethodType: .bankCard,
            confirmationTypes: [],
            charge: charge,
            identificationRequirement: nil,
            fee: fee?.paymentsModel,
            savePaymentMethod: .allowed
        ),
        PaymentOption(
            paymentMethodType: .applePay,
            confirmationTypes: [],
            charge: charge,
            identificationRequirement: nil,
            fee: fee?.paymentsModel,
            savePaymentMethod: .forbidden
        ),
    ]

    return response
}
