protocol BankCardRouterInput: AnyObject {
    func presentTermsOfServiceModule(_ url: URL)
    func presentSafeDealInfo(title: String, body: String)
    func presentSavePaymentMethodInfo(inputData: SavePaymentMethodInfoModuleInputData)
}
