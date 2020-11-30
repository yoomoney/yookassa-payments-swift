import UIKit.UIViewController
import struct YooKassaWalletApi.AuthTypeState

enum WalletAuthAssembly {
    static func makeModule(inputData: WalletAuthModuleInputData,
                           moduleOutput: WalletAuthModuleOutput?) -> UIViewController {
        let viewController = ContractViewController()
        let presenter = WalletAuthPresenter(inputData: inputData)

        let analyticsService = AnalyticsProcessingAssembly.makeAnalyticsService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsProvider = AnalyticsProvidingAssembly.makeAnalyticsProvider(
            testModeSettings: inputData.testModeSettings
        )
        let interactor = ContractInteractor(analyticsService: analyticsService,
                                            analyticsProvider: analyticsProvider)

        let itemView
            = ContractViewFactory.makePaymentMethodView(paymentMethod: inputData.paymentMethod,
                                                        viewOutput: presenter,
                                                        shouldChangePaymentMethod: inputData.shouldChangePaymentMethod)

        let authCodeType = makeAuthCodeType(authTypeState: inputData.authTypeState)

        let authCodeInputViewController = AuthCodeInputViewController(authCodeType: authCodeType)
        viewController.templateViewController.addChild(authCodeInputViewController)

        viewController.output = presenter
        viewController.paymentMethodView = itemView
        viewController.additionalView = authCodeInputViewController.view
        viewController.templateViewController.output = presenter

        authCodeInputViewController.didMove(toParent: viewController.templateViewController)
        authCodeInputViewController.output = presenter

        presenter.view = viewController
        presenter.interactor = interactor
        presenter.contractView = viewController.templateViewController
        presenter.moduleOutput = moduleOutput
        presenter.paymentMethodView = itemView
        presenter.authCodeInputView = authCodeInputViewController

        return viewController
    }
}

private func makeAuthCodeType(authTypeState: AuthTypeState) -> AuthCodeType {
    switch authTypeState.specific {
    case .sms:
        return .sms
    case .totp(_):
        return .totp
    default:
        assertionFailure("Unsupported type")
        return .sms
    }
}
