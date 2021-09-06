import MoneyAuth
import YooKassaPaymentsApi

protocol PaymentMethodsInteractorInput: AnalyticsTrack, AnalyticsProvider {
    func fetchPaymentMethods()
    func fetchYooMoneyPaymentMethods(moneyCenterAuthToken: String)
    func fetchAccount(oauthToken: String)
    func decryptCryptogram(_ cryptogram: String)
    func getWalletDisplayName() -> String?
    func setAccount(_ account: UserAccount)
    func startAnalyticsService()
    func stopAnalyticsService()

    // MARK: - Apple Pay Tokenize

    func tokenizeApplePay(paymentData: String, savePaymentMethod: Bool, amount: MonetaryAmount)
    func tokenizeInstrument(
        instrument: PaymentInstrumentBankCard,
        savePaymentMethod: Bool,
        returnUrl: String?,
        amount: MonetaryAmount
    )
    func unbindCard(id: String)
}

protocol PaymentMethodsInteractorOutput: AnyObject {
    func didFetchShop(_: Shop)
    func didFailFetchShop(_ error: Error)

    func didFetchYooMoneyPaymentMethods(_ paymentMethods: [PaymentOption], shopProperties: ShopProperties)
    func didFetchYooMoneyPaymentMethods(_ error: Error)

    func didFetchAccount(_ account: UserAccount)
    func didFailFetchAccount(_ error: Error)

    func didDecryptCryptogram(_ token: String)
    func didFailDecryptCryptogram(_ error: Error)

    func didTokenizeApplePay(_ token: Tokens)
    func failTokenizeApplePay(_ error: Error)

    func didUnbindCard(id: String)
    func didFailUnbindCard(id: String, error: Error)

    func didTokenizeInstrument(instrument: PaymentInstrumentBankCard, tokens: Tokens)
    func didFailTokenizeInstrument(error: Error)
}
