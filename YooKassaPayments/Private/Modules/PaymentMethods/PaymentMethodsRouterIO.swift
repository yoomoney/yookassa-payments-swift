import MoneyAuth

protocol PaymentMethodsRouterInput: class {
    func presentYooMoney(
        inputData: YooMoneyModuleInputData,
        moduleOutput: YooMoneyModuleOutput?
    )
    
    func closeYooMoneyModule()
    
    func presentLinkedCard(
        inputData: LinkedCardModuleInputData,
        moduleOutput: LinkedCardModuleOutput?
    )
    
    func closeLinkedCardModule()
    
    func presentYooMoneyAuthorizationModule(
        config: MoneyAuth.Config,
        customization: MoneyAuth.Customization,
        output: MoneyAuth.AuthorizationCoordinatorDelegate
    ) throws -> MoneyAuth.AuthorizationCoordinator

    func closeAuthorizationModule()
    
    func presentApplePay(
        inputData: ApplePayModuleInputData,
        moduleOutput: ApplePayModuleOutput
    )
    
    func closeApplePay(
        completion: (() -> Void)?
    )
    
    func presentApplePayContractModule(
        inputData: ApplePayContractModuleInputData,
        moduleOutput: ApplePayContractModuleOutput
    )
    
    func closeApplePayContractModule()

    func shouldDismissAuthorizationModule() -> Bool
}
