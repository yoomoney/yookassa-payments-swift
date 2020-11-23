import MoneyAuth

protocol YooMoneyAuthRouterInput: class {
    func presentAuthorizationModule(
        config: MoneyAuth.Config,
        customization: MoneyAuth.Customization,
        kassaPaymentsCustomization: CustomizationSettings,
        output: MoneyAuth.AuthorizationCoordinatorDelegate
    ) throws -> MoneyAuth.AuthorizationCoordinator

    func closeAuthorizationModule()

    func shouldDismissAuthorizationModule() -> Bool
}
