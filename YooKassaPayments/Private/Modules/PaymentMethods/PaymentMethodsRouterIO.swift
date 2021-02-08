import MoneyAuth

protocol PaymentMethodsRouterInput: class {
    func presentYooMoney(
        inputData: YooMoneyModuleInputData,
        moduleOutput: YooMoneyModuleOutput?
    )
    
    func closeYooMoneyModule()
    
    func presentYooMoneyAuthorizationModule(
        config: MoneyAuth.Config,
        customization: MoneyAuth.Customization,
        output: MoneyAuth.AuthorizationCoordinatorDelegate
    ) throws -> MoneyAuth.AuthorizationCoordinator

    func closeAuthorizationModule()

    func shouldDismissAuthorizationModule() -> Bool
}
