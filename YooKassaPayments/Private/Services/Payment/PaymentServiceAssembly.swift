enum PaymentServiceAssembly {
    static func makeService(
        tokenizationSettings: TokenizationSettings,
        testModeSettings: TestModeSettings?,
        isLoggingEnabled: Bool
    ) -> PaymentService {
        let service: PaymentService
        let paymentMethodHandlerService = PaymentMethodHandlerServiceAssembly
            .makeService(tokenizationSettings)

        switch testModeSettings {
        case .some(let testModeSettings):
            let keyValueStoring = KeyValueStoringAssembly.makeMockKeychainStorage(
                testModeSettings: testModeSettings
            )
            service = PaymentServiceMock(
                paymentMethodHandlerService: paymentMethodHandlerService,
                testModeSettings: testModeSettings,
                keyValueStoring: keyValueStoring
            )
        case .none:
            let session = ApiSessionAssembly
                .makeApiSession(isLoggingEnabled: isLoggingEnabled)
            service = PaymentServiceImpl(
                session: session,
                paymentMethodHandlerService: paymentMethodHandlerService
            )
        }
        return service
    }
}
