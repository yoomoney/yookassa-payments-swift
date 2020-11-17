import class YooKassaPaymentsApi.PaymentOption

struct YooMoneyAuthModuleInputData {
    let tokenizationSettings: TokenizationSettings
    let testModeSettings: TestModeSettings?
    let clientApplicationKey: String
    let gatewayId: String?
    let amount: Amount
    let isLoggingEnabled: Bool
    let getSavePaymentMethod: Bool?
    let moneyAuthClientId: String?
    let paymentMethodsModuleInput: PaymentMethodsModuleInput?
    let kassaPaymentsCustomization: CustomizationSettings
}

protocol YooMoneyAuthModuleInput: class {}

protocol YooMoneyAuthModuleOutput: class {

    func yooMoneyAuthModule(
        _ module: YooMoneyAuthModuleInput,
        didFetchWalletPaymentMethod paymentMethod: PaymentOption,
        tmxSessionId: String?
    )

    func didFetchWalletPaymentMethods(
        on module: YooMoneyAuthModuleInput,
        tmxSessionId: String?
    )

    func didFetchWalletPaymentMethodsWithoutWallet(on module: YooMoneyAuthModuleInput)
    func didFailFetchWalletPaymentMethods(on module: YooMoneyAuthModuleInput)
    func didCancelAuthorizeInYooMoney(on module: YooMoneyAuthModuleInput)

}
