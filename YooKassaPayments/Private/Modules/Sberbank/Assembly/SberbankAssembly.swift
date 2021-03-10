import UIKit

enum SberbankAssembly {
    static func makeModule(
        inputData: SberbankModuleInputData,
        moduleOutput: SberbankModuleOutput?
    ) -> UIViewController {
        let view = SberbankViewController()
        let presenter = SberbankPresenter(
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            priceViewModel: inputData.priceViewModel,
            feeViewModel: inputData.feeViewModel,
            termsOfService: inputData.termsOfService,
            userPhoneNumber: inputData.userPhoneNumber,
            isBackBarButtonHidden: inputData.isBackBarButtonHidden
        )
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let analyticsProvider = AnalyticsProviderAssembly.makeProvider(
            testModeSettings: inputData.testModeSettings
        )
        let analyticsService = AnalyticsServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        let interactor = SberbankInteractor(
            paymentService: paymentService,
            analyticsProvider: analyticsProvider,
            analyticsService: analyticsService,
            clientApplicationKey: inputData.clientApplicationKey,
            amount: inputData.paymentOption.charge.plain
        )
        let router = SberbankRouter()

        let (phoneNumberView, phoneNumberInput) = PhoneNumberInputAssembly.makeModule(
            moduleOutput: presenter
        )

        view.output = presenter
        view.phoneNumberInputView = phoneNumberView

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.moduleOutput = moduleOutput
        presenter.phoneNumberModuleInput = phoneNumberInput

        interactor.output = presenter

        router.transitionHandler = view

        return view
    }
}
