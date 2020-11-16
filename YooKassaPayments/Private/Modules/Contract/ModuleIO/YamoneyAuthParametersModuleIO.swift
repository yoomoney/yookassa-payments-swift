import Foundation
import struct YooKassaPaymentsApi.MonetaryAmount
import class YooKassaPaymentsApi.PaymentOption

struct YamoneyAuthParametersModuleInputData {
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

protocol YamoneyAuthParametersModuleInput: ContractStateHandler {}

protocol YamoneyAuthParametersModuleOutput: class {
    func yamoneyAuthParameters(
        _ module: YamoneyAuthParametersModuleInput,
        loginWithReusableToken isReusableToken: Bool
    )
    func didPressLogoutButton(
        on module: YamoneyAuthParametersModuleInput
    )
    func didPressChangeAction(
        on module: YamoneyAuthParametersModuleInput
    )
    func didFinish(
        on module: YamoneyAuthParametersModuleInput
    )
    func yamoneyAuthParameters(
        _ module: YamoneyAuthParametersModuleInput,
        didTapTermsOfService url: URL
    )
    func yamoneyAuthParameters(
        _ module: YamoneyAuthParametersModuleInput,
        didChangeSavePaymentMethodState state: Bool
    )
    func didTapOnSavePaymentMethodInfo(
        on module: YamoneyAuthParametersModuleInput
    )
}
