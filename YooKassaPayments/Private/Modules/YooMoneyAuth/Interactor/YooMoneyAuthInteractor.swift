final class YooMoneyAuthInteractor {

    // VIPER module properties

    weak var output: YooMoneyAuthInteractorOutput?

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

// MARK: - YooMoneyAuthInteractorInput

extension YooMoneyAuthInteractor: YooMoneyAuthInteractorInput {
    func fetchYooMoneyPaymentMethods(
        moneyCenterAuthToken: String,
        walletDisplayName: String?
    ) {
        authorizationService.setMoneyCenterAuthToken(moneyCenterAuthToken)
        authorizationService.setWalletDisplayName(walletDisplayName)

        let paymentMethods = paymentService.fetchPaymentOptions(
            clientApplicationKey: clientApplicationKey,
            authorizationToken: moneyCenterAuthToken,
            gatewayId: gatewayId,
            amount: amount.value.description,
            currency: amount.currency.rawValue,
            getSavePaymentMethod: getSavePaymentMethod
        )

        let yoomoneyPaymentMethods = paymentMethods.map {
            $0.filter {
                $0.paymentMethodType == .yooMoney
            }
        }

        guard let output = output else { return }

        yoomoneyPaymentMethods.done(output.didFetchYooMoneyPaymentMethods)
        yoomoneyPaymentMethods.fail(output.didFetchYooMoneyPaymentMethods)
    }

    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }
}
