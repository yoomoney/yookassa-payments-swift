import class YooKassaPaymentsApi.PaymentOption
import UIKit

protocol YooMoneyInteractorInput: AnyObject {
    func loginInWallet(
        amount: MonetaryAmount,
        reusableToken: Bool,
        tmxSessionId: String?
    )

    func tokenize(
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount,
        tmxSessionId: String?
    )

    func loadAvatar()

    func hasReusableWalletToken() -> Bool

    func track(event: AnalyticsEvent)
    func analyticsAuthType() -> AnalyticsEvent.AuthType

    func getWalletDisplayName() -> String?
    func logout()
}

protocol YooMoneyInteractorOutput: AnyObject {
    func didLoginInWallet(
        _ response: WalletLoginResponse
    )
    func failLoginInWallet(
        _ error: Error
    )

    func didTokenizeData(
        _ token: Tokens
    )
    func failTokenizeData(
        _ error: Error
    )

    func didLoadAvatar(
        _ avatar: UIImage
    )
    func didFailLoadAvatar(
        _ error: Error
    )
}
