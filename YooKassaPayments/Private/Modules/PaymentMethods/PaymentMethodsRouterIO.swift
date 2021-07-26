import MoneyAuth

protocol PaymentMethodsRouterInput: AnyObject {
    func presentYooMoney(
        inputData: YooMoneyModuleInputData,
        moduleOutput: YooMoneyModuleOutput?
    )

    func closeYooMoneyModule()

    func presentLinkedCard(
        inputData: LinkedCardModuleInputData,
        moduleOutput: LinkedCardModuleOutput?
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
        moduleOutput: ApplePayContractModuleOutput
    )

    func shouldDismissAuthorizationModule() -> Bool

    func openSberbankModule(
        inputData: SberbankModuleInputData,
        moduleOutput: SberbankModuleOutput
    )

    func openSberpayModule(
        inputData: SberpayModuleInputData,
        moduleOutput: SberpayModuleOutput
    )

    func openBankCardModule(
        inputData: BankCardModuleInputData,
        moduleOutput: BankCardModuleOutput?
    )

    func openCardSecModule(
        inputData: CardSecModuleInputData,
        moduleOutput: CardSecModuleOutput
    )

    func closeCardSecModule()
}
