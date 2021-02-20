protocol TokenizationRouterInput: class {

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


    func presentTermsOfServiceModule(
        _ url: URL
    )
    func presentSavePaymentMethodInfo(
        inputData: SavePaymentMethodInfoModuleInputData
    )
}
