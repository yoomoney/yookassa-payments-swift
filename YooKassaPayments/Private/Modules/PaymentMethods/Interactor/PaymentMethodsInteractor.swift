import MoneyAuth

class PaymentMethodsInteractor {

    // MARK: - VIPER

    weak var output: PaymentMethodsInteractorOutput?

    // MARK: - Init data

    private let paymentService: PaymentService
    private let authorizationService: AuthorizationService
    private let analyticsService: AnalyticsService
    private let analyticsProvider: AnalyticsProvider

    private let clientApplicationKey: String
    private let gatewayId: String?
    private let amount: Amount
    private let getSavePaymentMethod: Bool?

    // MARK: - Init

    init(
        paymentService: PaymentService,
        authorizationService: AuthorizationService,
        analyticsService: AnalyticsService,
        analyticsProvider: AnalyticsProvider,
        clientApplicationKey: String,
        gatewayId: String?,
        amount: Amount,
        getSavePaymentMethod: Bool?
    ) {
        self.paymentService = paymentService
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider

        self.clientApplicationKey = clientApplicationKey
        self.gatewayId = gatewayId
        self.amount = amount
        self.getSavePaymentMethod = getSavePaymentMethod
    }
}

extension PaymentMethodsInteractor: PaymentMethodsInteractorInput {
    func fetchPaymentMethods() {
        let authorizationToken = authorizationService.getMoneyCenterAuthToken()

        paymentService.fetchPaymentOptions(
            clientApplicationKey: clientApplicationKey,
            authorizationToken: authorizationToken,
            gatewayId: gatewayId,
            amount: amount.value.description,
            currency: amount.currency.rawValue,
            getSavePaymentMethod: getSavePaymentMethod
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case let .success(data):
                output.didFetchPaymentMethods(data)
            case let .failure(error):
                output.didFetchPaymentMethods(error)
            }
        }
    }
    
    func fetchYooMoneyPaymentMethods(
        moneyCenterAuthToken: String
    ) {
        authorizationService.setMoneyCenterAuthToken(moneyCenterAuthToken)

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
            case let .success(data):
                output.didFetchYooMoneyPaymentMethods(data.filter { $0.paymentMethodType == .yooMoney })
            case let .failure(error):
                output.didFetchYooMoneyPaymentMethods(error)
            }
        }
    }
    
    func getWalletDisplayName() -> String? {
        return authorizationService.getWalletDisplayName()
    }
    
    func setAccount(_ account: UserAccount) {
        authorizationService.setWalletDisplayName(account.displayName.title)
        authorizationService.setWalletPhoneTitle(account.phone.title)
        authorizationService.setWalletAvatarURL(account.avatar.url?.absoluteString)
    }

    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }

    func makeTypeAnalyticsParameters() -> (authType: AnalyticsEvent.AuthType,
                                           tokenType: AnalyticsEvent.AuthTokenType?) {
        return analyticsProvider.makeTypeAnalyticsParameters()
    }
}
