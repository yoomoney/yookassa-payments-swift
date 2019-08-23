enum PaymentProcessingAssembly {
    static func makeService(tokenizationSettings: TokenizationSettings,
                            testModeSettings: TestModeSettings?,
                            isLoggingEnabled: Bool) -> PaymentProcessing {
        let service: PaymentProcessing
        let paymentMethodHandler = PaymentMethodHandler.makePaymentMethodHandler(tokenizationSettings)
        let authorizationMediator = AuthorizationProcessingAssembly
            .makeService(isLoggingEnabled: isLoggingEnabled,
                         testModeSettings: testModeSettings)

        switch testModeSettings {
        case .some(let testModeSettings):
            service = MockPaymentService(paymentMethodHandler: paymentMethodHandler,
                                         testModeSettings: testModeSettings,
                                         authorizationMediator: authorizationMediator)
        case .none:
            let session = ApiSessionAssembly.makeApiSession(isLoggingEnabled: isLoggingEnabled)
            service = PaymentService(session: session,
                                     paymentMethodHandler: paymentMethodHandler)
        }

        return service
    }
}
