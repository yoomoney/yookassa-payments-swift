import MoneyAuth

final class YooMoneyAuthRouter {
    weak var transitionHandler: TransitionHandler?
}

// MARK: - YooMoneyAuthRouterInput

extension YooMoneyAuthRouter: YooMoneyAuthRouterInput {
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

    func shouldDismissAuthorizationModule() -> Bool {
        return transitionHandler?.presentedViewController != nil
    }
}
