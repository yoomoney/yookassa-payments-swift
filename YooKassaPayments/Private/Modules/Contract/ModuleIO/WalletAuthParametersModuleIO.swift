import Foundation
import struct YooKassaPaymentsApi.MonetaryAmount
import class YooKassaPaymentsApi.PaymentOption

struct WalletAuthParametersModuleInputData {
    let shopName: String
    let purchaseDescription: String
    let paymentMethod: PaymentMethodViewModel
    let price: PriceViewModel
    let fee: PriceViewModel?
    let shouldChangePaymentMethod: Bool
    let paymentOption: PaymentOption
    let testModeSettings: TestModeSettings?
    let tokenizeScheme: AnalyticsEvent.TokenizeScheme
    let isLoggingEnabled: Bool
    let customizationSettings: CustomizationSettings
    let termsOfService: TermsOfService
    let savePaymentMethodViewModel: SavePaymentMethodViewModel?
}

protocol WalletAuthParametersModuleInput: ContractStateHandler {}

protocol WalletAuthParametersModuleOutput: class {
    func walletAuthParameters(
        _ module: WalletAuthParametersModuleInput,
        loginWithReusableToken isReusableToken: Bool
    )
    func didPressLogoutButton(
        on module: WalletAuthParametersModuleInput
    )
    func didPressChangeAction(
        on module: WalletAuthParametersModuleInput
    )
    func didFinish(
        on module: WalletAuthParametersModuleInput
    )
    func walletAuthParameters(
        _ module: WalletAuthParametersModuleInput,
        didTapTermsOfService url: URL
    )
    func walletAuthParameters(
        _ module: WalletAuthParametersModuleInput,
        didChangeSavePaymentMethodState state: Bool
    )
    func didTapOnSavePaymentMethodInfo(
        on module: WalletAuthParametersModuleInput
    )
}
