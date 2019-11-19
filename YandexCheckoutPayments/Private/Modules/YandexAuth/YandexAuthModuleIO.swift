import class YandexCheckoutPaymentsApi.PaymentOption

struct YandexAuthModuleInputData {
    let tokenizationSettings: TokenizationSettings
    let testModeSettings: TestModeSettings?
    let clientApplicationKey: String
    let gatewayId: String?
    let amount: Amount
    let isLoggingEnabled: Bool
    let savePaymentMethod: Bool?
}

protocol YandexAuthModuleInput: class {}

protocol YandexAuthModuleOutput: class {

    func yandexAuthModule(_ module: YandexAuthModuleInput,
                          didFetchYamoneyPaymentMethod paymentMethod: PaymentOption)

    func didFetchYamoneyPaymentMethods(on module: YandexAuthModuleInput)
    func didFetchYamoneyPaymentMethodsWithoutWallet(on module: YandexAuthModuleInput)
    func didFailFetchYamoneyPaymentMethods(on module: YandexAuthModuleInput)
    func didCancelAuthorizeInYandex(on module: YandexAuthModuleInput)

}
