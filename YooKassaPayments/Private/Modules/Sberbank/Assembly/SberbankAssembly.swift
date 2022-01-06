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
            isBackBarButtonHidden: inputData.isBackBarButtonHidden,
            isSafeDeal: inputData.isSafeDeal,
            clientSavePaymentMethod: inputData.clientSavePaymentMethod,
            isSavePaymentMethodAllowed: inputData.paymentOption.savePaymentMethod == .allowed,
            config: inputData.config
        )
        let paymentService = PaymentServiceAssembly.makeService(
            tokenizationSettings: inputData.tokenizationSettings,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled
        )

        let analyticsService = AnalyticsTrackingAssembly.make(isLoggingEnabled: inputData.isLoggingEnabled)
        let threatMetrixService = ThreatMetrixServiceFactory.makeService()
        let authService = AuthorizationServiceAssembly.makeService(
            isLoggingEnabled: inputData.isLoggingEnabled,
            testModeSettings: inputData.testModeSettings,
            moneyAuthClientId: nil
        )
        let interactor = SberbankInteractor(
            authService: authService,
            paymentService: paymentService,
            analyticsService: analyticsService,
            threatMetrixService: threatMetrixService,
            clientApplicationKey: inputData.clientApplicationKey,
            amount: inputData.paymentOption.charge.plain,
            customerId: inputData.customerId
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
