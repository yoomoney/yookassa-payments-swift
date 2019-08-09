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
    func fetchPaymentOptions(clientApplicationKey: String,
                             passportToken: String?,
                             gatewayId: String?,
                             amount: String?,
                             currency: String?) -> Promise<[PaymentOption]> {

        let method = PaymentOptions.Method(oauthToken: clientApplicationKey,
                                           passportAuthorization: passportToken,
                                           gatewayId: gatewayId,
                                           amount: amount,
                                           currency: currency)

        let paymentOptions = session.perform(apiMethod: method).responseApi()

        let allItems = getItems <^> paymentOptions
        let items = paymentMethodHandler.filterPaymentMethods <^> allItems
        let itemsWithEmptyError = items
            .recover(on: .global(), mapError)
            .then(makeErrors)
        return itemsWithEmptyError
    }

    func tokenizeBankCard(clientApplicationKey: String,
                          bankCard: BankCard,
                          confirmation: Confirmation,
                          amount: MonetaryAmount?,
                          tmxSessionId: String) -> Promise<Tokens> {
        let paymentMethodData = PaymentMethodDataBankCard(bankCard: bankCard)
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation,
            paymentMethodData: paymentMethodData
        )
        let method = Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )
        let tokens = session.perform(apiMethod: method).responseApi()
        return tokens.recover(on: .global(), mapError)
    }

    func tokenizeWallet(clientApplicationKey: String,
                        yamoneyToken: String,
                        confirmation: Confirmation,
                        amount: MonetaryAmount?,
                        tmxSessionId: String) -> Promise<Tokens> {
        let paymentMethodData = PaymentInstrumentDataYandexMoneyWallet(
            instrumentType: .wallet,
            walletAuthorization: yamoneyToken
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation,
            paymentMethodData: paymentMethodData
        )
        let method = Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )
        let tokens = session.perform(apiMethod: method).responseApi()
        return tokens.recover(on: .global(), mapError)
    }

    func tokenizeLinkedBankCard(clientApplicationKey: String,
                                yamoneyToken: String,
                                cardId: String,
                                csc: String,
                                confirmation: Confirmation,
                                amount: MonetaryAmount?,
                                tmxSessionId: String) -> Promise<Tokens> {
        let paymentMethodData = PaymentInstrumentDataYandexMoneyLinkedBankCard(
            instrumentType: .linkedBankCard,
            cardId: cardId,
            csc: csc,
            walletAuthorization: yamoneyToken
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation,
            paymentMethodData: paymentMethodData
        )
        let method = Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )
        let tokens = session.perform(apiMethod: method).responseApi()
        return tokens.recover(on: .global(), mapError)
    }

    func tokenizeApplePay(clientApplicationKey: String,
                          paymentData: String,
                          amount: MonetaryAmount?,
                          tmxSessionId: String) -> Promise<Tokens> {
        let paymentMethodData = PaymentMethodDataApplePay(
            paymentData: paymentData
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount,
            tmxSessionId: tmxSessionId,
            confirmation: nil,
            paymentMethodData: paymentMethodData
        )
        let method = Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )
        let tokens = session.perform(apiMethod: method).responseApi()
        return tokens.recover(on: .global(), mapError)
    }

    func tokenizeSberbank(clientApplicationKey: String,
                          phoneNumber: String,
                          confirmation: Confirmation,
                          amount: MonetaryAmount?,
                          tmxSessionId: String) -> Promise<Tokens> {
        let paymentMethodData = PaymentMethodDataSberbank(
            phone: phoneNumber
        )
        let tokensRequest = TokensRequestPaymentMethodData(
            amount: amount,
            tmxSessionId: tmxSessionId,
            confirmation: confirmation,
            paymentMethodData: paymentMethodData
        )
        let method = Tokens.Method(
            oauthToken: clientApplicationKey,
            tokensRequest: tokensRequest
        )
        let tokens = session.perform(apiMethod: method).responseApi()
        return tokens.recover(on: .global(), mapError)
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
