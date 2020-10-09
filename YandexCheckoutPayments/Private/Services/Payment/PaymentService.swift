import FunctionalSwift
import When
import YandexCheckoutPaymentsApi
import YandexMoneyCoreApi

final class PaymentService {

    // MARK: - Services

    private let session: ApiSession
    private let paymentMethodHandler: PaymentMethodHandler

    // MARK: - Initializers

    init(session: ApiSession,
         paymentMethodHandler: PaymentMethodHandler) {
        self.session = session
        self.paymentMethodHandler = paymentMethodHandler
    }
}

// MARK: - PaymentProcessing

extension PaymentService: PaymentProcessing {

    func fetchPaymentOptions(
        clientApplicationKey: String,
        moneyCenterAuthorization: String?,
        gatewayId: String?,
        amount: String?,
        currency: String?,
        getSavePaymentMethod: Bool?
    ) -> Promise<[PaymentOption]> {

        let method = PaymentOptions.Method(
            oauthToken: clientApplicationKey,
            passportAuthorization: moneyCenterAuthorization,
            gatewayId: gatewayId,
            amount: amount,
            currency: currency,
            savePaymentMethod: getSavePaymentMethod
        )

        let paymentOptions = session.perform(apiMethod: method).responseApi()

        let allItems = getItems <^> paymentOptions
        let items = paymentMethodHandler.filterPaymentMethods <^> allItems
        let itemsWithEmptyError = items
            .recover(on: .global(), mapError)
            .then(makeErrors)
        return itemsWithEmptyError
    }

    func fetchPaymentMethod(
        clientApplicationKey: String,
        paymentMethodId: String
    ) -> Promise<YandexCheckoutPaymentsApi.PaymentMethod> {
        let method = YandexCheckoutPaymentsApi.PaymentMethod.Method(
            oauthToken: clientApplicationKey,
            paymentMethodId: paymentMethodId
        )
        let response = session.perform(apiMethod: method).responseApi()
        return response.recover(on: .global(), mapError)
    }

    func tokenizeBankCard(
        clientApplicationKey: String,
        bankCard: BankCard,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens> {
        let paymentMethodData = PaymentMethodDataBankCard(bankCard: bankCard)
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData
        )
        let method = Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )
        let tokens = session.perform(apiMethod: method).responseApi()
        return tokens.recover(on: .global(), mapError)
    }

    func tokenizeWallet(
        clientApplicationKey: String,
        walletAuthorization: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens> {
        let paymentMethodData = PaymentInstrumentDataYandexMoneyWallet(
            instrumentType: .wallet,
            walletAuthorization: walletAuthorization,
            paymentMethodType: paymentMethodType
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData
        )
        let method = Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )
        let tokens = session.perform(apiMethod: method).responseApi()
        return tokens.recover(on: .global(), mapError)
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
        tmxSessionId: String
    ) -> Promise<Tokens> {
        let paymentMethodData = PaymentInstrumentDataYandexMoneyLinkedBankCard(
            instrumentType: .linkedBankCard,
            cardId: cardId,
            csc: csc,
            walletAuthorization: walletAuthorization,
            paymentMethodType: paymentMethodType
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData
        )
        let method = Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )
        let tokens = session.perform(apiMethod: method).responseApi()
        return tokens.recover(on: .global(), mapError)
    }

    func tokenizeApplePay(
        clientApplicationKey: String,
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens> {
        let paymentMethodData = PaymentMethodDataApplePay(
            paymentData: paymentData
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount,
            tmxSessionId: tmxSessionId,
            confirmation: nil,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData
        )
        let method = Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )
        let tokens = session.perform(apiMethod: method).responseApi()
        return tokens.recover(on: .global(), mapError)
    }

    func tokenizeSberbank(
        clientApplicationKey: String,
        phoneNumber: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String
    ) -> Promise<Tokens> {
        let paymentMethodData = PaymentMethodDataSberbank(
            phone: phoneNumber
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod,
            paymentMethodData: paymentMethodData
        )
        let method = Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )
        let tokens = session.perform(apiMethod: method).responseApi()
        return tokens.recover(on: .global(), mapError)
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
        let tokensRequest = TokensRequestPaymentMethodId(
            amount: amount,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod,
            paymentMethodId: paymentMethodId,
            csc: csc
        )
        let method = Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )
        let response = session.perform(apiMethod: method).responseApi()
        return response.recover(on: .global(), mapError)
    }
}

private func getItems(_ model: PaymentOptions) -> [PaymentOption] {
    return model.items
}

private func mapError<T>(_ error: Error) throws -> Promise<T> {
    switch error {
    case let error as NSError where error.domain == NSURLErrorDomain:
        throw PaymentProcessingError.internetConnection
    default:
        throw error
    }
}

private func makeErrors(_ models: [PaymentOption]) throws -> [PaymentOption] {
    if models.isEmpty { throw PaymentProcessingError.emptyList }
    return models
}
