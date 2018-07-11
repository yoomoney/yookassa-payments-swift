protocol TokenizationRouterInput: class {

    func presentPaymentMethods(inputData: PaymentMethodsModuleInputData,
                               moduleOutput: PaymentMethodsModuleOutput)

    func presentContract(inputData: ContractModuleInputData,
                         moduleOutput: ContractModuleOutput)

    func presentSberbank(inputData: SberbankModuleInputData,
                         moduleOutput: SberbankModuleOutput)

    func presentYandexAuth(inputData: YandexAuthModuleInputData,
                           moduleOutput: YandexAuthModuleOutput)

    func presentYamoneyAuthParameters(inputData: YamoneyAuthParametersModuleInputData,
                                      moduleOutput: YamoneyAuthParametersModuleOutput)

    func presentYamoneyAuth(inputData: YamoneyAuthModuleInputData,
                            moduleOutput: YamoneyAuthModuleOutput)

    func presentBankCardDataInput(inputData: BankCardDataInputModuleInputData,
                                  moduleOutput: BankCardDataInputModuleOutput)

    func presentLinkedBankCardDataInput(inputData: LinkedBankCardDataInputModuleInputData,
                                        moduleOutput: LinkedBankCardDataInputModuleOutput)

    func presentLogoutConfirmation(inputData: LogoutConfirmationModuleInputData,
                                   moduleOutput: LogoutConfirmationModuleOutput)

    func present3dsModule(inputData: CardSecModuleInputData,
                          moduleOutput: CardSecModuleOutput)

    func presentApplePay(inputData: ApplePayModuleInputData,
                         moduleOutput: ApplePayModuleOutput)

    func presentError(inputData: ErrorModuleInputData,
                      moduleOutput: ErrorModuleOutput)
}
