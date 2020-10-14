enum PaymentProcessingAssembly {
    static func makeService(tokenizationSettings: TokenizationSettings,
                            testModeSettings: TestModeSettings?,
                            isLoggingEnabled: Bool) -> PaymentProcessing {
        let service: PaymentProcessing
        let paymentMethodHandler = PaymentMethodHandler
            .makePaymentMethodHandler(tokenizationSettings)

        let keyValueStoring: KeyValueStoring
        switch testModeSettings {
        case .some(let testModeSettings):
            keyValueStoring = KeyValueStoringAssembly.makeMockKeychainStorage(
                testModeSettings: testModeSettings
            )
        case .none:
            keyValueStoring = KeyValueStoringAssembly.makeKeychainStorage()
        }
        switch testModeSettings {
        case .some(let testModeSettings):
            service = MockPaymentService(
                paymentMethodHandler: paymentMethodHandler,
                testModeSettings: testModeSettings,
                keyValueStoring: keyValueStoring
            )
        case .none:
            let session = ApiSessionAssembly
                .makeApiSession(isLoggingEnabled: isLoggingEnabled)
            service = PaymentService(
                session: session,
                paymentMethodHandler: paymentMethodHandler
            )
        }
        return service
    }
}
