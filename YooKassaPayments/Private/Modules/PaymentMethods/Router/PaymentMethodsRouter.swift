import MoneyAuth

final class PaymentMethodsRouter {
    
    // MARK: - VIPER
    
    weak var transitionHandler: TransitionHandler?
}

// MARK: - PaymentMethodsRouterInput

extension PaymentMethodsRouter: PaymentMethodsRouterInput {
    func presentYooMoney(
        inputData: YooMoneyModuleInputData,
        moduleOutput: YooMoneyModuleOutput?,
        needReplace: Bool
    ) {
        let viewController = YooMoneyAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        if needReplace {
            transitionHandler?.replaceViewControllers(
                [viewController],
                animated: true
            )
        } else {
            transitionHandler?.push(
                viewController,
                animated: true
            )
        }
    }
    
    func closeYooMoneyModule() {
        transitionHandler?.popTopViewController(animated: true)
    }
    
    func presentLinkedCard(
        inputData: LinkedCardModuleInputData,
        moduleOutput: LinkedCardModuleOutput?,
        needReplace: Bool
    ) {
        let viewController = LinkedCardAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        if needReplace {
            transitionHandler?.replaceViewControllers(
                [viewController],
                animated: true
            )
        } else {
            transitionHandler?.push(
                viewController,
                animated: true
            )
        }
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
        viewController.view.tintColor = CustomizationStorage.shared.mainScheme
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
        moduleOutput: ApplePayContractModuleOutput,
        needReplace: Bool
    ) {
        let viewController = ApplePayContractAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        if needReplace {
            transitionHandler?.replaceViewControllers(
                [viewController],
                animated: true
            )
        } else {
            transitionHandler?.push(
                viewController,
                animated: true
            )
        }
    }

    func shouldDismissAuthorizationModule() -> Bool {
        return transitionHandler?.presentedViewController != nil
    }

    func openSberbankModule(
        inputData: SberbankModuleInputData,
        moduleOutput: SberbankModuleOutput,
        needReplace: Bool
    ) {
        let viewController = SberbankAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )
        if needReplace {
            transitionHandler?.replaceViewControllers(
                [viewController],
                animated: true
            )
        } else {
            transitionHandler?.push(
                viewController,
                animated: true
            )
        }
    }
}
