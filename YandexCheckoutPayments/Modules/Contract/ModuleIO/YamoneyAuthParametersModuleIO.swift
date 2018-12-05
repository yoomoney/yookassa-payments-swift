import Foundation
import struct YandexCheckoutPaymentsApi.MonetaryAmount
import class YandexCheckoutPaymentsApi.PaymentOption

struct YamoneyAuthParametersModuleInputData {
    let shopName: String
    let purchaseDescription: String
    let paymentMethod: PaymentMethodViewModel
    let price: PriceViewModel
    let shouldChangePaymentMethod: Bool
    let paymentOption: PaymentOption
    let testModeSettings: TestModeSettings?
    let tokenizeScheme: AnalyticsEvent.TokenizeScheme
    let isLoggingEnabled: Bool
}

protocol YamoneyAuthParametersModuleInput: ContractStateHandler {}

protocol YamoneyAuthParametersModuleOutput: class {
    func yamoneyAuthParameters(_ module: YamoneyAuthParametersModuleInput,
                               loginWithReusableToken isReusableToken: Bool)
    func didPressLogoutButton(on module: YamoneyAuthParametersModuleInput)
    func didPressChangeAction(on module: YamoneyAuthParametersModuleInput)
    func didFinish(on module: YamoneyAuthParametersModuleInput)
}
