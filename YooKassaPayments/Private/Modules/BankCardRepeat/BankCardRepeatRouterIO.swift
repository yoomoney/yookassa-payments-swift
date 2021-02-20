protocol BankCardRepeatRouterInput: class {
    func presentTermsOfServiceModule(_ url: URL)
    
    func presentSavePaymentMethodInfo(
        inputData: SavePaymentMethodInfoModuleInputData
    )
    
    func present3dsModule(
        inputData: CardSecModuleInputData,
        moduleOutput: CardSecModuleOutput
    )

    func closeCardSecModule()
}
