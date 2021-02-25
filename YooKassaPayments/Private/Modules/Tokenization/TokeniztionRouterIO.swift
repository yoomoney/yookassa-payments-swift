protocol TokenizationRouterInput: class {

    func presentContract(
        inputData: ContractModuleInputData,
        moduleOutput: ContractModuleOutput
    )

    func presentTermsOfServiceModule(
        _ url: URL
    )
    func presentSavePaymentMethodInfo(
        inputData: SavePaymentMethodInfoModuleInputData
    )
}
