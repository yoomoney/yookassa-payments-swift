import MoneyAuth

final class YandexAuthRouter {
    weak var transitionHandler: TransitionHandler?
}

// MARK: - YandexAuthRouterInput

extension YandexAuthRouter: YandexAuthRouterInput {
    func presentAuthorizationModule(
        config: MoneyAuth.Config,
        customization: MoneyAuth.Customization,
        kassaPaymentsCustomization: CustomizationSettings,
        output: MoneyAuth.AuthorizationCoordinatorDelegate
    ) throws -> MoneyAuth.AuthorizationCoordinator {

        let coordinator = MoneyAuth.AuthorizationCoordinator(
            processType: .login,
            config: config,
            customization: customization
        )
        coordinator.delegate = output
        let viewController = try coordinator.makeInitialViewController()
        viewController.view.tintColor = kassaPaymentsCustomization.mainScheme
        transitionHandler?.present(viewController, animated: true, completion: nil)
        return coordinator
    }

    func closeAuthorizationModule() {
        transitionHandler?.dismiss(animated: true, completion: nil)
    }
}
