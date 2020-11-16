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
        didFetchYamoneyPaymentMethod paymentMethod: PaymentOption,
        tmxSessionId: String?
    )

    func didFetchYamoneyPaymentMethods(
        on module: YooMoneyAuthModuleInput,
        tmxSessionId: String?
    )

    func didFetchYamoneyPaymentMethodsWithoutWallet(on module: YooMoneyAuthModuleInput)
    func didFailFetchYamoneyPaymentMethods(on module: YooMoneyAuthModuleInput)
    func didCancelAuthorizeInYooMoney(on module: YooMoneyAuthModuleInput)

}
