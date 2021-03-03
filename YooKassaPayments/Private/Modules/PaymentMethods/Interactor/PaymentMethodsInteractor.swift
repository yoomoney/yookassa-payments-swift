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

        if !ThreatMetrixService.isConfigured {
            ThreatMetrixService.configure()
        }
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

    func startAnalyticsService() {
        analyticsService.start()
    }

    func stopAnalyticsService() {
        analyticsService.stop()
    }
}

// MARK: - Apple Pay Tokenize

extension PaymentMethodsInteractor {
    func tokenizeApplePay(
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount
    ) {
        ThreatMetrixService.profileApp { [weak self] result in
            guard let self = self,
                  let output = self.output else { return }

            switch result {
            case let .success(tmxSessionId):
                self.tokenizeApplePayWithTMXSessionId(
                    paymentData: paymentData,
                    savePaymentMethod: savePaymentMethod,
                    amount: amount,
                    tmxSessionId: tmxSessionId
                )

            case let .failure(error):
                let mappedError = mapError(error)
                output.failTokenizeApplePay(mappedError)
            }
        }
    }
    
    private func tokenizeApplePayWithTMXSessionId(
        paymentData: String,
        savePaymentMethod: Bool,
        amount: MonetaryAmount,
        tmxSessionId: String
    ) {
        guard let output = output else { return }

        let completion: (Result<Tokens, Error>) -> Void = { result in
            switch result {
            case let .success(data):
                output.didTokenizeApplePay(data)
            case let .failure(error):
                let mappedError = mapError(error)
                output.failTokenizeApplePay(mappedError)
            }
        }

        paymentService.tokenizeApplePay(
            clientApplicationKey: clientApplicationKey,
            paymentData: paymentData,
            savePaymentMethod: savePaymentMethod,
            amount: amount,
            tmxSessionId: tmxSessionId,
            completion: completion
        )
    }
}

private func mapError(_ error: Error) -> Error {
    switch error {
    case ThreatMetrixService.ProfileError.connectionFail:
        return PaymentProcessingError.internetConnection
    case let error as NSError where error.domain == NSURLErrorDomain:
        return PaymentProcessingError.internetConnection
    default:
        return error
    }
}
