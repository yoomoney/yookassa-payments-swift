import YooKassaPaymentsApi
import MoneyAuth

protocol PaymentMethodsInteractorInput: AnalyticsTrack, AnalyticsProvider {
    func fetchPaymentMethods()
    
    func fetchYooMoneyPaymentMethods(
        moneyCenterAuthToken: String
    )
    
    func getWalletDisplayName() -> String?
    
    func setAccount(_ account: UserAccount)
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
}
