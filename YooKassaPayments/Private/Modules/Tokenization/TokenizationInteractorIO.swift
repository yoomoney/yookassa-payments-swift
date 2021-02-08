import YooKassaPaymentsApi

enum TokenizeData {
    case bankCard(bankCard: BankCard, confirmation: Confirmation, savePaymentMethod: Bool)
    case wallet(confirmation: Confirmation, savePaymentMethod: Bool)
    case linkedBankCard(id: String, csc: String, confirmation: Confirmation, savePaymentMethod: Bool)
    case applePay(paymentData: String, savePaymentMethod: Bool)
    case sberbank(phoneNumber: String, confirmation: Confirmation, savePaymentMethod: Bool)
}

protocol TokenizationInteractorInput: AnalyticsTrack, AnalyticsProvider {
    func tokenize(
        _ data: TokenizeData,
        paymentOption: PaymentOption,
        tmxSessionId: String?
    )

    func loginInWallet(
        reusableToken: Bool,
        paymentOption: PaymentOption,
        tmxSessionId: String?
    )

    func loginInWallet(
        authContextId: String,
        authType: AuthType,
        answer: String,
        processId: String
    )

    func getWalletDisplayName() -> String?
    func logout()
    func startAnalyticsService()
    func stopAnalyticsService()
}

protocol TokenizationInteractorOutput: class {
    func didTokenizeData(_ token: Tokens)
    func failTokenizeData(_ error: Error)

    func didLoginInWallet(_ response: WalletLoginResponse)
    func failLoginInWallet(_ error: Error)
}
