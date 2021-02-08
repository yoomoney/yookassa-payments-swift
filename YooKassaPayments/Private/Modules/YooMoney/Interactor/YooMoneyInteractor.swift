import YooKassaPaymentsApi

final class YooMoneyInteractor {

    // MARK: - VIPER

    weak var output: YooMoneyInteractorOutput?

    // MARK: - Init data
    
    fileprivate let authorizationService: AuthorizationService
    fileprivate let analyticsService: AnalyticsService
    fileprivate let paymentService: PaymentService
    fileprivate let analyticsProvider: AnalyticsProvider
    fileprivate let imageDownloadService: ImageDownloadService

    fileprivate let clientApplicationKey: String

    // MARK: - Init

    init(
        authorizationService: AuthorizationService,
        analyticsService: AnalyticsService,
        analyticsProvider: AnalyticsProvider,
        paymentService: PaymentService,
        imageDownloadService: ImageDownloadService,
        clientApplicationKey: String
    ) {
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider
        self.paymentService = paymentService
        self.imageDownloadService = imageDownloadService
        self.clientApplicationKey = clientApplicationKey
    }
}

// MARK: - YooMoneyInteractorInput

extension YooMoneyInteractor: YooMoneyInteractorInput {
    func loginInWallet(
        amount: MonetaryAmount,
        reusableToken: Bool,
        tmxSessionId: String?
    ) {
        authorizationService.loginInWallet(
            merchantClientAuthorization: clientApplicationKey,
            amount: amount,
            reusableToken: reusableToken,
            tmxSessionId: tmxSessionId
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case let .success(response):
                output.didLoginInWallet(response)
            case let .failure(error):
                let mappedError = mapError(error)
                output.failLoginInWallet(mappedError)
            }
        }
    }
    
    func tokenize(
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount,
        tmxSessionId: String?
    ) {
        if let tmxSessionId = tmxSessionId {
            tokenizeWithTMXSessionId(
                confirmation: confirmation,
                savePaymentMethod: savePaymentMethod,
                paymentMethodType: paymentMethodType,
                amount: amount,
                tmxSessionId: tmxSessionId
            )
        } else {
            ThreatMetrixService.profileApp { [weak self] result in
                guard let self = self,
                      let output = self.output else { return }

                switch result {
                case let .success(tmxSessionId):
                    self.tokenizeWithTMXSessionId(
                        confirmation: confirmation,
                        savePaymentMethod: savePaymentMethod,
                        paymentMethodType: paymentMethodType,
                        amount: amount,
                        tmxSessionId: tmxSessionId
                    )

                case let .failure(error):
                    let mappedError = mapError(error)
                    output.failTokenizeData(mappedError)
                }
            }
        }
    }
    
    func loadAvatar() {
        guard let avatarURL = authorizationService.getWalletAvatarURL(),
              let url = URL(string: avatarURL) else {
            return
        }
        
        imageDownloadService.fetchImage(url: url) { [weak self] result in
            guard let self = self,
                  let output = self.output else { return }
            
            switch result {
            case let .success(avatar):
                output.didLoadAvatar(avatar)
            case let .failure(error):
                output.didFailLoadAvatar(error)
            }
        }
    }
    
    func hasReusableWalletToken() -> Bool {
        return authorizationService.hasReusableWalletToken()
    }

    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }
    
    func makeTypeAnalyticsParameters() -> (
        authType: AnalyticsEvent.AuthType,
        tokenType: AnalyticsEvent.AuthTokenType?
    ) {
        return analyticsProvider.makeTypeAnalyticsParameters()
    }
    
    func stopAnalyticsService() {
        analyticsService.stop()
    }
    
    func getWalletDisplayName() -> String? {
        return authorizationService.getWalletDisplayName()
    }
    
    func logout() {
        authorizationService.logout()
    }
    
    private func tokenizeWithTMXSessionId(
        confirmation: Confirmation,
        savePaymentMethod: Bool,
        paymentMethodType: PaymentMethodType,
        amount: MonetaryAmount,
        tmxSessionId: String
    ) {
        guard let output = output else { return }

        let completion: (Result<Tokens, Error>) -> Void = { result in
            switch result {
            case let .success(data):
                output.didTokenizeData(data)
            case let .failure(error):
                let mappedError = mapError(error)
                output.failTokenizeData(mappedError)
            }
        }

        guard let walletToken = authorizationService.getWalletToken() else {
            assertionFailure("You must be authorized in wallet")
            return
        }

        paymentService.tokenizeWallet(
            clientApplicationKey: clientApplicationKey,
            walletAuthorization: walletToken,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod,
            paymentMethodType: paymentMethodType,
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
