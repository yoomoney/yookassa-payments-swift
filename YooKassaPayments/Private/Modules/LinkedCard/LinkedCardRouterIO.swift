protocol LinkedCardRouterInput: AnyObject {
    func presentTermsOfServiceModule(_ url: URL)

    func presentPaymentAuthorizationModule(
        inputData: PaymentAuthorizationModuleInputData,
        moduleOutput: PaymentAuthorizationModuleOutput?
    )

    func closePaymentAuthorization()
}
