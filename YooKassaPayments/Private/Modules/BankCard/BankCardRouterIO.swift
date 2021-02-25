protocol BankCardRouterInput: class {
    func presentTermsOfServiceModule(
        _ url: URL
    )
    func presentSavePaymentMethodInfo(
        inputData: SavePaymentMethodInfoModuleInputData
    )
}
