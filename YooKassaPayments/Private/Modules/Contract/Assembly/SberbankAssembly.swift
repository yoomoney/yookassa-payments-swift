import UIKit

enum SberbankAssembly {
    static func makeModule(
        inputData: SberbankModuleInputData,
        moduleOutput: SberbankModuleOutput?
    ) -> UIViewController {
        let viewController = ContractViewController()
        let presenter = SberbankPresenter(inputData: inputData)

        let (phoneController, phoneModuleInput) = PhoneNumberInputAssembly.makeModule(moduleOutput: presenter)

        viewController.templateViewController.addChild(phoneController)

        let analyticsService = AnalyticsServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsProvider = AnalyticsProviderAssembly.makeProvider(
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

        viewController.output = presenter
        viewController.paymentMethodView = itemView
        viewController.additionalView = phoneController.view
        viewController.templateViewController.output = presenter

        presenter.view = viewController
        presenter.interactor = interactor
        presenter.moduleOutput = moduleOutput
        presenter.paymentMethodView = itemView
        presenter.contractView = viewController.templateViewController
        presenter.phoneInputView = phoneModuleInput

        return viewController
    }
}
