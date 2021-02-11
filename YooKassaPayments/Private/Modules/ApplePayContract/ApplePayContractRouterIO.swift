protocol ApplePayContractRouterInput: class {
    func presentTermsOfServiceModule(_ url: URL)
    
    func presentSavePaymentMethodInfo(
        inputData: SavePaymentMethodInfoModuleInputData
    )
    
    func presentApplePay(
        inputData: ApplePayModuleInputData,
        moduleOutput: ApplePayModuleOutput
    )
    
    func closeApplePay(
        completion: (() -> Void)?
    )
}
