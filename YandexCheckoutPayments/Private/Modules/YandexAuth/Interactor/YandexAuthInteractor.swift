final class YandexAuthInteractor {

    // VIPER module properties

    weak var output: YandexAuthInteractorOutput?

    private let authorizationService: AuthorizationProcessing
    private let analyticsService: AnalyticsProcessing
    private let paymentService: PaymentProcessing

    // MARK: - Data properties

    private let clientApplicationKey: String
    private let gatewayId: String?
    private let amount: Amount
    private let getSavePaymentMethod: Bool?

    init(authorizationService: AuthorizationProcessing,
         analyticsService: AnalyticsProcessing,
         paymentService: PaymentProcessing,
         clientApplicationKey: String,
         gatewayId: String?,
         amount: Amount,
         getSavePaymentMethod: Bool?) {
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.paymentService = paymentService
        self.clientApplicationKey = clientApplicationKey
        self.gatewayId = gatewayId
        self.amount = amount
        self.getSavePaymentMethod = getSavePaymentMethod
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

        let paymentMethods = paymentService.fetchPaymentOptions(
            clientApplicationKey: clientApplicationKey,
            passportToken: passportToken,
            gatewayId: gatewayId,
            amount: amount.value.description,
            currency: amount.currency.rawValue,
            getSavePaymentMethod: getSavePaymentMethod
        )

        let yamoneyPaymentMethods = paymentMethods.map { $0.filter { $0.paymentMethodType == .yandexMoney } }

        guard let output = output else { return }

        yamoneyPaymentMethods.done(output.didFetchYamoneyPaymentMethods)
        yamoneyPaymentMethods.fail(output.didFetchYamoneyPaymentMethods)
    }

    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }
}
