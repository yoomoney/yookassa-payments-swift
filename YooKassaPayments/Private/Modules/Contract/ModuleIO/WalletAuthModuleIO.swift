import Foundation
import struct YooKassaPaymentsApi.MonetaryAmount
import enum YooKassaWalletApi.AuthType
import struct YooKassaWalletApi.AuthTypeState

struct WalletAuthModuleInputData {
    let shopName: String
    let purchaseDescription: String
    let paymentMethod: PaymentMethodViewModel
    let price: PriceViewModel
    let fee: PriceViewModel?
    let processId: String
    let authContextId: String
    let authTypeState: AuthTypeState
    let shouldChangePaymentMethod: Bool
    let testModeSettings: TestModeSettings?
    let tokenizeScheme: AnalyticsEvent.TokenizeScheme
    let isLoggingEnabled: Bool
    let termsOfService: TermsOfService
}

protocol WalletAuthModuleInput: ContractStateHandler {
    func setAuthTypeState(
        _ authTypeState: AuthTypeState
    )
    func failResendSmsCode(
        _ error: Error
    )
}

protocol WalletAuthModuleOutput: class {
    func walletAuth(
        _ module: WalletAuthModuleInput,
        resendSmsCodeWithContextId authContextId: String,
        authType: AuthType
    )
    func walletAuth(
        _ module: WalletAuthModuleInput,
        authContextId: String,
        authType: AuthType,
        answer: String,
        processId: String
    )
    func walletAuth(
        _ module: WalletAuthModuleInput,
        didFinishWithError error: Error
    )
    func didPressLogoutButton(
        on module: WalletAuthModuleInput
    )
    func didFinish(
        on module: WalletAuthModuleInput
    )
    func didPressChangeAction(
        on module: WalletAuthModuleInput
    )
    func walletAuth(
        _ module: WalletAuthModuleInput,
        didTapTermsOfService url: URL
    )
}
