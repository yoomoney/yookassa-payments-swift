import UIKit

private var configPreloader: ConfigMediator?

/// Tokenization module builder.
public enum TokenizationAssembly {

    /// Creates tokenization view controller.
    ///
    /// - Returns: Tokenization view controller which implements the protocol `TokenizationModuleInput`.
    public static func makeModule(
        inputData: TokenizationFlow,
        moduleOutput: TokenizationModuleOutput
    ) -> UIViewController & TokenizationModuleInput {
        switch inputData {
        case .tokenization(let tokenizationModuleInputData):
            CustomizationStorage.shared.mainScheme
                = tokenizationModuleInputData.customizationSettings.mainScheme
            return makeTokenizationModule(tokenizationModuleInputData, moduleOutput: moduleOutput)

        case .bankCardRepeat(let bankCardRepeatModuleInputData):
            CustomizationStorage.shared.mainScheme
                = bankCardRepeatModuleInputData.customizationSettings.mainScheme
            return makeBankCardRepeatModule(bankCardRepeatModuleInputData, moduleOutput: moduleOutput)
        }
    }

    private static func makeBankCardRepeatModule(
        _ inputData: BankCardRepeatModuleInputData,
        moduleOutput: TokenizationModuleOutput
    ) -> UIViewController & TokenizationModuleInput {
        let (viewController, moduleInput) = BankCardRepeatAssembly.makeModule(
            inputData: inputData,
            moduleOutput: moduleOutput
        )

        let navigationController = UINavigationController(
            rootViewController: viewController
        )

        let sheetViewController = SheetViewController(
            contentViewController: navigationController
        )
        sheetViewController.moduleOutput = moduleInput

        return sheetViewController
    }

    private static func makeTokenizationModule(
        _ inputData: TokenizationModuleInputData,
        moduleOutput: TokenizationModuleOutput
    ) -> UIViewController & TokenizationModuleInput {

        PrintLogger.forceSilence = !inputData.isLoggingEnabled

        func paymentMethodsModule(config: Config) -> (view: UIViewController, moduleInput: PaymentMethodsModuleInput) {
            let paymentMethodsModuleInputData = PaymentMethodsModuleInputData(
                applicationScheme: inputData.applicationScheme,
                clientApplicationKey: inputData.clientApplicationKey,
                applePayMerchantIdentifier: inputData.applePayMerchantIdentifier,
                gatewayId: inputData.gatewayId,
                shopName: inputData.shopName,
                purchaseDescription: inputData.purchaseDescription,
                amount: inputData.amount,
                tokenizationSettings: inputData.tokenizationSettings,
                testModeSettings: inputData.testModeSettings,
                isLoggingEnabled: inputData.isLoggingEnabled,
                getSavePaymentMethod: inputData.boolFromSavePaymentMethod,
                moneyAuthClientId: inputData.moneyAuthClientId,
                returnUrl: inputData.returnUrl,
                savePaymentMethod: inputData.savePaymentMethod,
                userPhoneNumber: inputData.userPhoneNumber,
                cardScanning: inputData.cardScanning,
                customerId: inputData.customerId,
                config: config
            )

            return PaymentMethodsAssembly.makeModule(
                inputData: paymentMethodsModuleInputData,
                tokenizationModuleOutput: moduleOutput
            )
        }

        let loading = LoadingViewController()
        let navigationController = NavigationController(rootViewController: loading)
        loading.showActivity()

        let viewControllerToReturn: UIViewController & TokenizationModuleInput
        var resultingNavigationController: NavigationController?
        var resultingSheetViewController: SheetViewController?
        switch UIScreen.main.traitCollection.userInterfaceIdiom {
        case .pad:
            navigationController.modalPresentationStyle = .formSheet
            viewControllerToReturn = navigationController
            resultingNavigationController = navigationController
        default:
            let sheetViewController = SheetViewController(
                contentViewController: navigationController
            )
            viewControllerToReturn = sheetViewController
            resultingSheetViewController = sheetViewController
        }

        let authService = AuthorizationServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled,
            testModeSettings: inputData.testModeSettings,
            moneyAuthClientId: inputData.moneyAuthClientId
        )

        YKSdk.shared.moduleOutput = moduleOutput
        YKSdk.shared.applicationScheme = inputData.applicationScheme

        let preloader = ConfigMediatorAssembly.make(isLoggingEnabled: inputData.isLoggingEnabled)
        configPreloader = preloader
        preloader.getConfig(token: inputData.clientApplicationKey) { config in
            DispatchQueue.main.async {
                let (viewController, moduleInput) = paymentMethodsModule(config: config)
                resultingNavigationController?.moduleOutput = moduleInput
                resultingSheetViewController?.moduleOutput = moduleInput
                YKSdk.shared.paymentMethodsModuleInput = moduleInput

                loading.hideActivity()
                navigationController.setViewControllers([viewController], animated: true)
            }

            configPreloader = nil
        }

        YKSdk.shared.analyticsTracking = AnalyticsTrackingAssembly.make(isLoggingEnabled: inputData.isLoggingEnabled)
        YKSdk.shared.analyticsContext = AnalyticsEventContext(
            sdkVersion: Bundle.frameworkVersion,
            initialAuthType: authService.analyticsAuthType(),
            isCustomerIdPresent: inputData.customerId != nil,
            isWalletAuthPresent: authService.getWalletToken() != nil,
            usingCustomColor: inputData.customizationSettings.mainScheme != CustomizationColors.blueRibbon,
            yookassaIconShown: inputData.tokenizationSettings.showYooKassaLogo,
            savePaymentMethod: inputData.savePaymentMethod
        )

        YKSdk.shared.analyticsTracking.track(event: .actionSDKInitialised)

        return viewControllerToReturn
    }
}
