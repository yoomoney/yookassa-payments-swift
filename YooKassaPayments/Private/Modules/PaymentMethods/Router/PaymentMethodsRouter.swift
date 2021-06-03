import MoneyAuth

final class PaymentMethodsRouter {

    // MARK: - VIPER

    weak var transitionHandler: TransitionHandler?
}

// MARK: - PaymentMethodsRouterInput

extension PaymentMethodsRouter: PaymentMethodsRouterInput {
    func presentYooMoney(
        inputData: YooMoneyModuleInputData,
        moduleOutput: YooMoneyModuleOutput?
    ) {
        let viewController = YooMoneyAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(
            viewController,
            animated: true
        )
    }

    func closeYooMoneyModule() {
        transitionHandler?.popTopViewController(animated: true)
    }

    func presentLinkedCard(
        inputData: LinkedCardModuleInputData,
        moduleOutput: LinkedCardModuleOutput?
    ) {
        let viewController = LinkedCardAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(
            viewController,
            animated: true
        )
    }

    func presentYooMoneyAuthorizationModule(
        config: MoneyAuth.Config,
        customization: MoneyAuth.Customization,
        output: MoneyAuth.AuthorizationCoordinatorDelegate
    ) throws -> MoneyAuth.AuthorizationCoordinator {

        let coordinator = MoneyAuth.AuthorizationCoordinator(
            processType: .login,
            config: config,
            customization: customization
        )
        coordinator.delegate = output
        let viewController = try coordinator.makeInitialViewController()
        transitionHandler?.present(
            viewController,
            animated: true,
            completion: nil
        )
        return coordinator
    }

    func closeAuthorizationModule() {
        transitionHandler?.dismiss(animated: true, completion: nil)
    }

    func presentApplePay(
        inputData: ApplePayModuleInputData,
        moduleOutput: ApplePayModuleOutput
    ) {
        if let viewController = ApplePayAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        ) {
            moduleOutput.didPresentApplePayModule()
            transitionHandler?.present(
                viewController,
                animated: true,
                completion: nil
            )
        } else {
            moduleOutput.didFailPresentApplePayModule()
        }
    }

    func closeApplePay(
        completion: (() -> Void)?
    ) {
        transitionHandler?.dismiss(
            animated: true,
            completion: completion
        )
    }

    func presentApplePayContractModule(
        inputData: ApplePayContractModuleInputData,
        moduleOutput: ApplePayContractModuleOutput
    ) {
        let viewController = ApplePayContractAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(
            viewController,
            animated: true
        )
    }

    func shouldDismissAuthorizationModule() -> Bool {
        return transitionHandler?.presentedViewController != nil
    }

    func openSberbankModule(
        inputData: SberbankModuleInputData,
        moduleOutput: SberbankModuleOutput
    ) {
        let viewController = SberbankAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(
            viewController,
            animated: true
        )
    }

    func openSberpayModule(
        inputData: SberpayModuleInputData,
        moduleOutput: SberpayModuleOutput
    ) {
        let viewController = SberpayAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(
            viewController,
            animated: true
        )
    }

    func openBankCardModule(
        inputData: BankCardModuleInputData,
        moduleOutput: BankCardModuleOutput?
    ) {
        let viewController = BankCardAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        transitionHandler?.push(
            viewController,
            animated: true
        )
    }

    func openCardSecModule(
        inputData: CardSecModuleInputData,
        moduleOutput: CardSecModuleOutput
    ) {
        let viewController = CardSecAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        let navigationController = UINavigationController(
            rootViewController: viewController
        )
        transitionHandler?.present(
            navigationController,
            animated: true,
            completion: nil
        )
    }

    func closeCardSecModule() {
        transitionHandler?.dismiss(
            animated: true,
            completion: nil
        )
    }
}
