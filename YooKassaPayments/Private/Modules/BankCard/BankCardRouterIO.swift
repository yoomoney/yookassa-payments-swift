protocol BankCardRouterInput: AnyObject {
    func presentTermsOfServiceModule(
        _ url: URL
    )
    func presentSavePaymentMethodInfo(
        inputData: SavePaymentMethodInfoModuleInputData
    )
}
