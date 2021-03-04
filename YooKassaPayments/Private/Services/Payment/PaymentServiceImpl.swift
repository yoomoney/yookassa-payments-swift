import YooKassaPaymentsApi
import YooMoneyCoreApi

final class PaymentServiceImpl {

    // MARK: - Init data

    private let session: ApiSession
    private let paymentMethodHandlerService: PaymentMethodHandlerService

    // MARK: - Init

    init(
        session: ApiSession,
        paymentMethodHandlerService: PaymentMethodHandlerService
    ) {
        self.session = session
        self.paymentMethodHandlerService = paymentMethodHandlerService
    }
}

// MARK: - PaymentService

extension PaymentServiceImpl: PaymentService {
    func fetchPaymentOptions(
        clientApplicationKey: String,
        authorizationToken: String?,
        gatewayId: String?,
        amount: String?,
        currency: String?,
        getSavePaymentMethod: Bool?,
        completion: @escaping (Result<[PaymentOption], Error>) -> Void
    ) {

        let apiMethod = PaymentOptions.Method(
            oauthToken: clientApplicationKey,
            authorization: authorizationToken,
            gatewayId: gatewayId,
            amount: amount,
            currency: currency,
            savePaymentMethod: getSavePaymentMethod
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .left(error):
                let mappedError = mapError(error)
                completion(.failure(mappedError))
            case let .right(data):
                let items = self.paymentMethodHandlerService.filterPaymentMethods(data.items)
                if items.isEmpty {
                    completion(.failure(PaymentProcessingError.emptyList))
                } else {
                    completion(.success(items))
                }
            }
        }
    }

    func fetchPaymentMethod(
        clientApplicationKey: String,
        paymentMethodId: String,
        completion: @escaping (Result<PaymentMethod, Error>) -> Void
    ) {
        let apiMethod = YooKassaPaymentsApi.PaymentMethod.Method(
            oauthToken: clientApplicationKey,
            paymentMethodId: paymentMethodId
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .left(error):
                let mappedError = mapError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
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
        let paymentMethodData = PaymentMethodDataBankCard(bankCard: bankCard.paymentsModel)
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount?.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation.paymentsModel,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .left(error):
                let mappedError = mapError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
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
        let paymentMethodData = PaymentInstrumentDataYooMoneyWallet(
            instrumentType: .wallet,
            walletAuthorization: walletAuthorization,
            paymentMethodType: paymentMethodType.paymentsModel
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount?.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation.paymentsModel,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .left(error):
                let mappedError = mapError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
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
        let paymentMethodData = PaymentInstrumentDataYooMoneyLinkedBankCard(
            instrumentType: .linkedBankCard,
            cardId: cardId,
            csc: csc,
            walletAuthorization: walletAuthorization,
            paymentMethodType: paymentMethodType.paymentsModel
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount?.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation.paymentsModel,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .left(error):
                let mappedError = mapError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
    }

    func tokenizeApplePay(
        clientApplicationKey: String,
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        completion: @escaping (Result<Tokens, Error>) -> Void
    ) {
        let paymentMethodData = PaymentMethodDataApplePay(
            paymentData: paymentData
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount?.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: nil,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .left(error):
                let mappedError = mapError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
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
        let paymentMethodData = PaymentMethodDataSberbank(
            phone: phoneNumber
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount?.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation.paymentsModel,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .left(error):
                let mappedError = mapError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
    }
    
    func tokenizeSberpay(
        clientApplicationKey: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        completion: @escaping (Result<Tokens, Error>) -> Void
    ) {
        let paymentMethodData = PaymentMethodDataSberbank(
            phone: nil
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount?.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation.paymentsModel,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .left(error):
                let mappedError = mapError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
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
        let tokensRequest = TokensRequestPaymentMethodId(
            amount: amount.paymentsModel,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation.paymentsModel,
            savePaymentMethod: savePaymentMethod,
            paymentMethodId: paymentMethodId,
            csc: csc
        )
        let apiMethod = YooKassaPaymentsApi.Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )

        session.perform(apiMethod: apiMethod).responseApi(queue: .global()) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .left(error):
                let mappedError = mapError(error)
                completion(.failure(mappedError))
            case let .right(data):
                completion(.success(data.plain))
            }
        }
    }
}

private func mapError(_ error: Error) -> Error {
    switch error {
    case let error as NSError where error.domain == NSURLErrorDomain:
        return PaymentProcessingError.internetConnection
    default:
        return error
    }
}
