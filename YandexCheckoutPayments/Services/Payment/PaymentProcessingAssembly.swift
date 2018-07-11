enum PaymentProcessingAssembly {
    static func makeService(tokenizationSettings: TokenizationSettings,
                            testModeSettings: TestModeSettings?) -> PaymentProcessing {
        let service: PaymentProcessing
        let paymentMethodHandler = PaymentMethodHandler.makePaymentMethodHandler(tokenizationSettings)
        let authorizationMediator = AuthorizationProcessingAssembly.makeService(testModeSettings: testModeSettings)

        switch testModeSettings {
        case .some(let testModeSettings):
            service = MockPaymentService(paymentMethodHandler: paymentMethodHandler,
                                         testModeSettings: testModeSettings,
                                         authorizationMediator: authorizationMediator)
        case .none:
            service = PaymentService(session: ApiSessionAssembly.makeApiSession(),
                                     paymentMethodHandler: paymentMethodHandler)
        }

        return service
    }
}
