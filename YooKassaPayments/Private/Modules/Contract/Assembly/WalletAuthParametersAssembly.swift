import class UIKit.UIViewController
import class UIKit.UIView
import struct UIKit.UIEdgeInsets

enum WalletAuthParametersAssembly {
    static func makeModule(inputData: WalletAuthParametersModuleInputData,
                           moduleOutput: WalletAuthParametersModuleOutput?) -> UIViewController {
        let viewController = ContractViewController()
        let presenter = WalletAuthParametersPresenter(inputData: inputData)

        let analyticsService = AnalyticsProcessingAssembly.makeAnalyticsService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsProvider = AnalyticsProvidingAssembly.makeAnalyticsProvider(
            testModeSettings: inputData.testModeSettings
        )
        let interactor = ContractInteractor(
            analyticsService: analyticsService,
            analyticsProvider: analyticsProvider
        )

        let itemView = ContractViewFactory.makePaymentMethodView(
            paymentMethod: inputData.paymentMethod,
            viewOutput: presenter,
            shouldChangePaymentMethod: inputData.shouldChangePaymentMethod
        )

        let saveAuthInAppView = ContractViewFactory.makeSwitchItemView(
            inputData.customizationSettings
        )

        viewController.output = presenter
        viewController.paymentMethodView = itemView
        viewController.additionalView = saveAuthInAppView
        viewController.templateViewController.output = presenter

        saveAuthInAppView.delegate = presenter

        presenter.view = viewController
        presenter.interactor = interactor
        presenter.contractView = viewController.templateViewController
        presenter.moduleOutput = moduleOutput
        presenter.paymentMethodView = itemView
        presenter.isReusableTokenView = saveAuthInAppView

        return viewController
    }
}
