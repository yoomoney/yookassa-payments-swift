final class YandexAuthInteractor {

    // VIPER module properties

    weak var output: YandexAuthInteractorOutput?

    fileprivate let authorizationService: AuthorizationProcessing
    fileprivate let analyticsService: AnalyticsProcessing
    fileprivate let paymentService: PaymentProcessing

    // MARK: - Data properties

    fileprivate let clientApplicationKey: String
    fileprivate let gatewayId: String?
    fileprivate let amount: Amount

    init(authorizationService: AuthorizationProcessing,
         analyticsService: AnalyticsProcessing,
         paymentService: PaymentProcessing,
         clientApplicationKey: String,
         gatewayId: String?,
         amount: Amount) {
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.paymentService = paymentService
        self.clientApplicationKey = clientApplicationKey
        self.gatewayId = gatewayId
        self.amount = amount
    }
}

// MARK: - YandexAuthInteractorInput

extension YandexAuthInteractor: YandexAuthInteractorInput {

    func authorizeInYandex() {

        let token = authorizationService.loginInYandex()

        guard let output = output else { return }
        token.done(output.didAuthorizeInYandex)
        token.fail(output.didAuthorizeInYandex)
    }

    func fetchYamoneyPaymentMethods() {

        let passportToken = authorizationService.getYandexToken()

        let paymentMethods = paymentService.fetchPaymentOptions(clientApplicationKey: clientApplicationKey,
                                                                passportToken: passportToken,
                                                                gatewayId: gatewayId,
                                                                amount: amount.value.description,
                                                                currency: amount.currency.rawValue)

        let yamoneyPaymentMethods = paymentMethods.map { $0.filter { $0.paymentMethodType == .yandexMoney } }

        guard let output = output else { return }

        yamoneyPaymentMethods.done(output.didFetchYamoneyPaymentMethods)
        yamoneyPaymentMethods.fail(output.didFetchYamoneyPaymentMethods)
    }

    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }
}
