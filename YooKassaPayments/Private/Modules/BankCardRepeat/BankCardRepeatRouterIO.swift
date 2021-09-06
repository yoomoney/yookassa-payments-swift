protocol BankCardRepeatRouterInput: AnyObject {
    func presentTermsOfServiceModule(_ url: URL)
    func presentSafeDealInfo(title: String, body: String)
    func presentSavePaymentMethodInfo(inputData: SavePaymentMethodInfoModuleInputData)
    func present3dsModule(inputData: CardSecModuleInputData, moduleOutput: CardSecModuleOutput)
    func closeCardSecModule()
}
