import MoneyAuth

protocol PaymentMethodsRouterInput: class {
    func presentYooMoney(
        inputData: YooMoneyModuleInputData,
        moduleOutput: YooMoneyModuleOutput?,
        needReplace: Bool
    )
    
    func closeYooMoneyModule()
    
    func presentLinkedCard(
        inputData: LinkedCardModuleInputData,
        moduleOutput: LinkedCardModuleOutput?,
        needReplace: Bool
    )
    
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
        moduleOutput: ApplePayContractModuleOutput,
        needReplace: Bool
    )

    func shouldDismissAuthorizationModule() -> Bool

    func openSberbankModule(
        inputData: SberbankModuleInputData,
        moduleOutput: SberbankModuleOutput,
        needReplace: Bool
    )
}
