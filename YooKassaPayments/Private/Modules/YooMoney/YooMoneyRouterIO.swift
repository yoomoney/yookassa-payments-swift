import MoneyAuth

protocol YooMoneyRouterInput: AnyObject {
    func presentTermsOfServiceModule(_ url: URL)
    func presentSafeDealInfo(title: String, body: String)
    func presentSavePaymentMethodInfo(inputData: SavePaymentMethodInfoModuleInputData)
    func presentLogoutConfirmation(
        inputData: LogoutConfirmationModuleInputData,
        moduleOutput: LogoutConfirmationModuleOutput
    )
    func presentPaymentAuthorizationModule(
        inputData: PaymentAuthorizationModuleInputData,
        moduleOutput: PaymentAuthorizationModuleOutput?
    )
    func closePaymentAuthorization()
}
