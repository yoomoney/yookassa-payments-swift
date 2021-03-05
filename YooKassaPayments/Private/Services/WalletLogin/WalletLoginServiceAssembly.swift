enum WalletLoginServiceAssembly {
    static func makeService(
        isLoggingEnabled: Bool,
        testModeSettings: TestModeSettings?
    ) -> WalletLoginService {
        let service: WalletLoginService

        switch testModeSettings {
        case .some(let testModeSettings):
            service = WalletLoginServiceMock(
                paymentAuthorizationPassed: testModeSettings.paymentAuthorizationPassed
            )
        case .none:
            let session = ApiSessionAssembly.makeApiSession(
                isLoggingEnabled: isLoggingEnabled
            )
            service = WalletLoginServiceImpl(
                session: session,
                authTypeStatesService: AuthTypeStatesServiceImpl()
            )
        }

        return service
    }
}
