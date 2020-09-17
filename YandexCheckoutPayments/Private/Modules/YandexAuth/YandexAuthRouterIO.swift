import MoneyAuth

protocol YandexAuthRouterInput: class {
    func presentAuthorizationModule(
        config: MoneyAuth.Config,
        output: MoneyAuth.AuthorizationCoordinatorDelegate
    ) throws -> MoneyAuth.AuthorizationCoordinator

    func closeAuthorizationModule()
}
