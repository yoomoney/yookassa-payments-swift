import Foundation
import struct YooKassaPaymentsApi.MonetaryAmount
import enum YooKassaWalletApi.AuthType
import struct YooKassaWalletApi.AuthTypeState

struct YamoneyAuthModuleInputData {
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

protocol YamoneyAuthModuleInput: ContractStateHandler {
    func setAuthTypeState(_ authTypeState: AuthTypeState)
    func failResendSmsCode(_ error: Error)
}

protocol YamoneyAuthModuleOutput: class {
    func yamoneyAuth(_ module: YamoneyAuthModuleInput,
                     resendSmsCodeWithContextId authContextId: String,
                     authType: AuthType)
    func yamoneyAuth(_ module: YamoneyAuthModuleInput,
                     authContextId: String,
                     authType: AuthType,
                     answer: String,
                     processId: String)
    func yamoneyAuth(_ module: YamoneyAuthModuleInput,
                     didFinishWithError error: Error)
    func didPressLogoutButton(on module: YamoneyAuthModuleInput)
    func didFinish(on module: YamoneyAuthModuleInput)
    func didPressChangeAction(on module: YamoneyAuthModuleInput)
    func yamoneyAuth(_ module: YamoneyAuthModuleInput,
                     didTapTermsOfService url: URL)
}
