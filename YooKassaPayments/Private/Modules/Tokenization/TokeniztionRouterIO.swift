protocol TokenizationRouterInput: class {

    func presentPaymentMethods(
        inputData: PaymentMethodsModuleInputData,
        moduleOutput: PaymentMethodsModuleOutput
    )

    func presentContract(
        inputData: ContractModuleInputData,
        moduleOutput: ContractModuleOutput
    )

    func presentSberbank(
        inputData: SberbankModuleInputData,
        moduleOutput: SberbankModuleOutput
    )

    func presentYooMoneyAuth(
        inputData: YooMoneyAuthModuleInputData,
        moduleOutput: YooMoneyAuthModuleOutput
    )

    func presentWalletAuthParameters(
        inputData: WalletAuthParametersModuleInputData,
        moduleOutput: WalletAuthParametersModuleOutput
    )

    func presentWalletAuth(
        inputData: WalletAuthModuleInputData,
        moduleOutput: WalletAuthModuleOutput
    )

    func presentBankCardDataInput(
        inputData: BankCardDataInputModuleInputData,
        moduleOutput: BankCardDataInputModuleOutput
    )

    func presenMaskedBankCardDataInput(
        inputData: MaskedBankCardDataInputModuleInputData,
        moduleOutput: MaskedBankCardDataInputModuleOutput
    )

    func presentLogoutConfirmation(
        inputData: LogoutConfirmationModuleInputData,
        moduleOutput: LogoutConfirmationModuleOutput
    )

    func present3dsModule(
        inputData: CardSecModuleInputData,
        moduleOutput: CardSecModuleOutput
    )

    func presentApplePay(
        inputData: ApplePayModuleInputData,
        moduleOutput: ApplePayModuleOutput
    )

    func presentError(
        inputData: ErrorModuleInputData,
        moduleOutput: ErrorModuleOutput
    )

    func presentTermsOfServiceModule(
        _ url: URL
    )

    func presentApplePayContract(
        inputData: ApplePayContractModuleInputData,
        moduleOutput: ApplePayContractModuleOutput
    )

    func presentSavePaymentMethodInfo(
        inputData: SavePaymentMethodInfoModuleInputData
    )
}
