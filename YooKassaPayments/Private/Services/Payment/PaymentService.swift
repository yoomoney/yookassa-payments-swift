import YooKassaPaymentsApi

protocol PaymentService {
    func fetchPaymentOptions(
        clientApplicationKey: String,
        authorizationToken: String?,
        gatewayId: String?,
        amount: String?,
        currency: String?,
        getSavePaymentMethod: Bool?,
        completion: @escaping (Result<[PaymentOption], Error>) -> Void
    )

    func fetchPaymentMethod(
        clientApplicationKey: String,
        paymentMethodId: String,
        completion: @escaping (Result<PaymentMethod, Error>) -> Void
    )

    func tokenizeBankCard(
        clientApplicationKey: String,
        bankCard: BankCard,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        completion: @escaping (Result<Tokens, Error>) -> Void
    )

    func tokenizeWallet(
        clientApplicationKey: String,
        walletAuthorization: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        completion: @escaping (Result<Tokens, Error>) -> Void
    )

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
    )

    func tokenizeSberbank(
        clientApplicationKey: String,
        phoneNumber: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        completion: @escaping (Result<Tokens, Error>) -> Void
    )

    func tokenizeApplePay(
        clientApplicationKey: String,
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount?,
        tmxSessionId: String,
        completion: @escaping (Result<Tokens, Error>) -> Void
    )

    func tokenizeRepeatBankCard(
        clientApplicationKey: String,
        amount: MonetaryAmount,
        tmxSessionId: String,
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodId: String,
        csc: String,
        completion: @escaping (Result<Tokens, Error>) -> Void
    )
}
