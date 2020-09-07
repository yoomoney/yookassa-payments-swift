struct AnalyticsProvider: AnalyticsProviding {

    private let authorizationService: AuthorizationProcessing

    init(authorizationService: AuthorizationProcessing) {
        self.authorizationService = authorizationService
    }

    func makeTypeAnalyticsParameters() -> (authType: AnalyticsEvent.AuthType,
                                           tokenType: AnalyticsEvent.AuthTokenType?) {

        let authType: AnalyticsEvent.AuthType
        let tokenType: AnalyticsEvent.AuthTokenType?

        if authorizationService.hasReusableYamoneyToken() {
            authType = .paymentAuth
            tokenType = .multiple
            // TODO: MOC-762
//        } else if authorizationService.getYandexToken() != nil {
//            authType = .yandexLogin
//            tokenType = .single
        } else {
            authType = .withoutAuth
            tokenType = nil
        }

        return (authType, tokenType)
    }
}
