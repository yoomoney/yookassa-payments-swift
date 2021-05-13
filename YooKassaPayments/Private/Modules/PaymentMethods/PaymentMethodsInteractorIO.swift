import YooKassaPaymentsApi
import MoneyAuth

protocol PaymentMethodsInteractorInput: AnalyticsTrack, AnalyticsProvider {
    func fetchPaymentMethods()
    
    func fetchYooMoneyPaymentMethods(
        moneyCenterAuthToken: String
    )
    
    func fetchAccount(
        oauthToken: String
    )
    
    func decryptCryptogram(
        _ cryptogram: String
    )
    
    func getWalletDisplayName() -> String?
    
    func setAccount(_ account: UserAccount)

    func startAnalyticsService()

    func stopAnalyticsService()
    
    // MARK: - Apple Pay Tokenize
    
    func tokenizeApplePay(
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount
    )
}

protocol PaymentMethodsInteractorOutput: class {
    func didFetchPaymentMethods(
        _ paymentMethods: [PaymentOption]
    )
    func didFetchPaymentMethods(
        _ error: Error
    )
    
    func didFetchYooMoneyPaymentMethods(
        _ paymentMethods: [PaymentOption]
    )
    func didFetchYooMoneyPaymentMethods(
        _ error: Error
    )
    
    func didFetchAccount(
        _ account: UserAccount
    )
    func didFailFetchAccount(
        _ error: Error
    )
    
    func didDecryptCryptogram(
        _ token: String
    )
    func didFailDecryptCryptogram(
        _ error: Error
    )
    
    func didTokenizeApplePay(
        _ token: Tokens
    )
    func failTokenizeApplePay(
        _ error: Error
    )
}
