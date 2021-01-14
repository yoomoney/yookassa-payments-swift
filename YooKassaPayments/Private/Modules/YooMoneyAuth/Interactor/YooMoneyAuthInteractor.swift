final class YooMoneyAuthInteractor {

    // VIPER module properties

    weak var output: YooMoneyAuthInteractorOutput?

    private let authorizationService: AuthorizationProcessing
    private let analyticsService: AnalyticsProcessing
    private let paymentService: PaymentService

    // MARK: - Data properties

    private let clientApplicationKey: String
    private let gatewayId: String?
    private let amount: Amount
    private let getSavePaymentMethod: Bool?

    init(authorizationService: AuthorizationProcessing,
         analyticsService: AnalyticsProcessing,
         paymentService: PaymentService,
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

        paymentService.fetchPaymentOptions(
            clientApplicationKey: clientApplicationKey,
            authorizationToken: moneyCenterAuthToken,
            gatewayId: gatewayId,
            amount: amount.value.description,
            currency: amount.currency.rawValue,
            getSavePaymentMethod: getSavePaymentMethod
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case .success(let data):
                output.didFetchYooMoneyPaymentMethods(data.filter { $0.paymentMethodType == .yooMoney })
            case .failure(let error):
                output.didFetchYooMoneyPaymentMethods(error)
            }
        }
    }

    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }
}
