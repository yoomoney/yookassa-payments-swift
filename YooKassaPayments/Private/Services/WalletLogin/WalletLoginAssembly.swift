import YooKassaWalletApi

enum WalletLoginAssembly {
    static func makeWalletLoginService(
        isLoggingEnabled: Bool,
        testModeSettings: TestModeSettings?
    ) -> WalletLoginProcessing {
        let service: WalletLoginProcessing

        switch testModeSettings {
        case .some(let testModeSettings):
            service = MockWalletLoginService(
                paymentAuthorizationPassed: testModeSettings.paymentAuthorizationPassed
            )
        case .none:
            let session = ApiSessionAssembly.makeApiSession(
                isLoggingEnabled: isLoggingEnabled
            )
            service = WalletLoginService(
                session: session,
                authTypeStatesService: AuthTypeStatesService()
            )
        }

        return service
    }
}
