import YooKassaPaymentsApi
import MoneyAuth

protocol PaymentMethodsInteractorInput: AnalyticsTrack, AnalyticsProvider {
    func fetchPaymentMethods()
    
    func fetchYooMoneyPaymentMethods(
        moneyCenterAuthToken: String
    )
    
    func getWalletDisplayName() -> String?
    
    func setAccount(_ account: UserAccount)
    
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
    
    func didTokenizeApplePay(
        _ token: Tokens
    )
    func failTokenizeApplePay(
        _ error: Error
    )
}
