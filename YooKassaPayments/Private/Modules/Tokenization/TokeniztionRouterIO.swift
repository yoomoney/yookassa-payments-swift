protocol TokenizationRouterInput: class {

    func presentPaymentMethods(
        inputData: PaymentMethodsModuleInputData,
        moduleOutput: PaymentMethodsModuleOutput
    )

    func presentContract(
        inputData: ContractModuleInputData,
        moduleOutput: ContractModuleOutput
    )

    func presentBankCardDataInput(
        inputData: BankCardDataInputModuleInputData,
        moduleOutput: BankCardDataInputModuleOutput
    )

    func presenMaskedBankCardDataInput(
        inputData: MaskedBankCardDataInputModuleInputData,
        moduleOutput: MaskedBankCardDataInputModuleOutput
    )

    func present3dsModule(
        inputData: CardSecModuleInputData,
        moduleOutput: CardSecModuleOutput
    )

    func presentError(
        inputData: ErrorModuleInputData,
        moduleOutput: ErrorModuleOutput
    )

    func presentTermsOfServiceModule(
        _ url: URL
    )
    func presentSavePaymentMethodInfo(
        inputData: SavePaymentMethodInfoModuleInputData
    )
}
