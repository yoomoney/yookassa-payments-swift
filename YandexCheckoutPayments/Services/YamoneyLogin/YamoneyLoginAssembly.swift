import YandexCheckoutWalletApi

enum YamoneyLoginAssembly {
    static func makeYamoneyLoginService(testModeSettings: TestModeSettings?) -> YamoneyLoginProcessing {
        let service: YamoneyLoginProcessing

        switch testModeSettings {
        case .some(let testModeSettings):
            service = MockYamoneyLoginService(paymentAuthorizationPassed: testModeSettings.paymentAuthorizationPassed)
        case .none:
            let session = ApiSessionAssembly.makeApiSession()
            service = YamoneyLoginService(session: session,
                                          authTypeStatesService: AuthTypeStatesService())
        }

        return service
    }
}
