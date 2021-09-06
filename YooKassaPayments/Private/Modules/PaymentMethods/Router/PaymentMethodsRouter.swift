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

    func openCardSettingsModule(data: CardSettingsModuleInputData, output: CardSettingsModuleOutput) {
        transitionHandler?.push(CardSettingsAssembly.make(data: data, output: output), animated: true)
    }

    func closeCardSettingsModule() {
        transitionHandler?.popTopViewController(animated: true)
    }

    func showUnbindAlert(unbindHandler: @escaping (UIAlertAction) -> Void) {
        let ctrl = UIAlertController(
            title: nil,
            message: CommonLocalized.CardSettingsDetails.autopaymentPersists,
            preferredStyle: .alert
        )
        let ok = UIAlertAction(
            title: Localized.Alert.unbindCard,
            style: .default,
            handler: unbindHandler
        )
        let cancel = UIAlertAction(
            title: Localized.Alert.cancel,
            style: .destructive,
            handler: nil
        )

        ctrl.view.tintColor = CustomizationStorage.shared.mainScheme
        ctrl.addAction(ok)
        ctrl.addAction(cancel)
        transitionHandler?.present(ctrl, animated: true, completion: nil)
    }

    // MARK: - Localized
    private enum Localized {
        enum Alert {
            static let unbindCard = NSLocalizedString(
                "PaymentMethods.alert.unbindCard",
                bundle: Bundle.framework,
                value: "Отвязать",
                comment: "Текст кнопки отвязать https://disk.yandex.ru/i/f9rYGyNbx2HJ0Q"
            )
            static let cancel = NSLocalizedString(
                "PaymentMethods.alert.cancel",
                bundle: Bundle.framework,
                value: "Отмена",
                comment: "Текст кнопки отвязать https://disk.yandex.ru/i/f9rYGyNbx2HJ0Q"
            )
        }
    }
}
