import MoneyAuth

protocol YandexAuthRouterInput: class {
    func presentAuthorizationModule(
        config: MoneyAuth.Config,
        output: MoneyAuth.ProcessCoordinatorDelegate
    ) throws -> MoneyAuth.ProcessCoordinator

    func closeAuthorizationModule()
}
