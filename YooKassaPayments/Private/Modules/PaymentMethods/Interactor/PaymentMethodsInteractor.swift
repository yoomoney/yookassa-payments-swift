import MoneyAuth
import ThreatMetrixAdapter
import YooKassaPaymentsApi

class PaymentMethodsInteractor {

    // MARK: - VIPER

    weak var output: PaymentMethodsInteractorOutput?

    // MARK: - Init data

    private let paymentService: PaymentService
    private let authorizationService: AuthorizationService
    private let analyticsService: AnalyticsService
    private let accountService: AccountService
    private let analyticsProvider: AnalyticsProvider
    private let threatMetrixService: ThreatMetrixService
    private let amountNumberFormatter: AmountNumberFormatter
    private let appDataTransferMediator: AppDataTransferMediator

    private let clientApplicationKey: String
    private let gatewayId: String?
    private let amount: Amount
    private let getSavePaymentMethod: Bool?
    private let customerId: String?

    // MARK: - Init

    init(
        paymentService: PaymentService,
        authorizationService: AuthorizationService,
        analyticsService: AnalyticsService,
        accountService: AccountService,
        analyticsProvider: AnalyticsProvider,
        threatMetrixService: ThreatMetrixService,
        amountNumberFormatter: AmountNumberFormatter,
        appDataTransferMediator: AppDataTransferMediator,
        clientApplicationKey: String,
        gatewayId: String?,
        amount: Amount,
        getSavePaymentMethod: Bool?,
        customerId: String?
    ) {
        self.paymentService = paymentService
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.accountService = accountService
        self.analyticsProvider = analyticsProvider
        self.threatMetrixService = threatMetrixService
        self.amountNumberFormatter = amountNumberFormatter
        self.appDataTransferMediator = appDataTransferMediator

        self.clientApplicationKey = clientApplicationKey
        self.gatewayId = gatewayId
        self.amount = amount
        self.getSavePaymentMethod = getSavePaymentMethod
        self.customerId = customerId
    }
}

extension PaymentMethodsInteractor: PaymentMethodsInteractorInput {
    func unbindCard(id: String) {
        paymentService.unbind(authToken: clientApplicationKey, id: id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.output?.didUnbindCard(id: id)
            case .failure(let error):
                self.output?.didFailUnbindCard(id: id, error: mapError(error))
            }
        }
    }

    func fetchPaymentMethods() {
        let authorizationToken = authorizationService.getMoneyCenterAuthToken()

        paymentService.fetchPaymentOptions(
            clientApplicationKey: clientApplicationKey,
            authorizationToken: authorizationToken,
            gatewayId: gatewayId,
            amount: amountNumberFormatter.string(from: amount.value),
            currency: amount.currency.rawValue,
            getSavePaymentMethod: getSavePaymentMethod,
            customerId: customerId
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case let .success(data):
                output.didFetchShop(data)
            case let .failure(error):
                output.didFailFetchShop(error)
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
            amount: amountNumberFormatter.string(from: amount.value),
            currency: amount.currency.rawValue,
            getSavePaymentMethod: getSavePaymentMethod,
            customerId: customerId
        ) { [weak self] result in
            guard let output = self?.output else { return }
            switch result {
            case let .success(data):
                output.didFetchYooMoneyPaymentMethods(
                    data.options.filter { $0.paymentMethodType == .yooMoney },
                    shopProperties: data.properties
                )
            case let .failure(error):
                output.didFetchYooMoneyPaymentMethods(error)
            }
        }
    }

    func fetchAccount(
        oauthToken: String
    ) {
        accountService.fetchAccount(
            oauthToken: oauthToken
        ) { [weak self] in
            guard let output = self?.output else { return }
            $0.map {
                output.didFetchAccount($0)
            }.mapLeft {
                output.didFailFetchAccount($0)
            }
        }
    }

    func decryptCryptogram(
        _ cryptogram: String
    ) {
        appDataTransferMediator.decryptData(cryptogram) { [weak self] in
            guard let output = self?.output else { return }
            $0.map {
                output.didDecryptCryptogram($0)
            }.mapLeft {
                output.didFailDecryptCryptogram($0)
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
        threatMetrixService.profileApp { [weak self] result in
            guard let self = self,
                  let output = self.output else { return }

            switch result {
            case let .success(tmxSessionId):
                self.tokenizeApplePayWithTMXSessionId(
                    paymentData: paymentData,
                    savePaymentMethod: savePaymentMethod,
                    amount: amount,
                    tmxSessionId: tmxSessionId.value
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
            customerId: customerId,
            completion: completion
        )
    }

    func tokenizeInstrument(
        instrument: PaymentInstrumentBankCard,
        savePaymentMethod: Bool,
        returnUrl: String?,
        amount: MonetaryAmount
    ) {
        threatMetrixService.profileApp { [weak self] result in
            guard let self = self, let output = self.output else { return }
            switch result {
            case .success(let tmxId):
                self.paymentService.tokenizeCardInstrument(
                    clientApplicationKey: self.clientApplicationKey,
                    amount: amount,
                    tmxSessionId: tmxId.value,
                    confirmation: Confirmation(type: .redirect, returnUrl: returnUrl),
                    savePaymentMethod: savePaymentMethod,
                    instrumentId: instrument.paymentInstrumentId,
                    csc: nil
                ) { tokenizeResult in
                    switch tokenizeResult {
                    case .success(let tokens):
                        output.didTokenizeInstrument(instrument: instrument, tokens: tokens)
                    case .failure(let error):
                        let mappedError = mapError(error)
                        output.didFailTokenizeInstrument(error: mappedError)
                    }
                }
            case .failure(let error):
                let mappedError = mapError(error)
                output.didFailTokenizeInstrument(error: mappedError)
            }
        }
    }
}

private func mapError(_ error: Error) -> Error {
    switch error {
    case ProfileError.connectionFail:
        return PaymentProcessingError.internetConnection
    case let error as NSError where error.domain == NSURLErrorDomain:
        return PaymentProcessingError.internetConnection
    default:
        return error
    }
}
