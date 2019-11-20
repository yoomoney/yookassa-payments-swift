import Foundation
import struct YandexCheckoutPaymentsApi.MonetaryAmount

class PaymentMethodsInteractor {

    // MARK: - VIPER module

    weak var output: PaymentMethodsInteractorOutput?

    private let paymentService: PaymentProcessing
    private let authorizationService: AuthorizationProcessing
    private let analyticsService: AnalyticsProcessing
    private let analyticsProvider: AnalyticsProviding

    // MARK: - Data properties

    private let clientApplicationKey: String
    private let gatewayId: String?
    private let amount: Amount
    private let savePaymentMethod: Bool?

    init(paymentService: PaymentProcessing,
         authorizationService: AuthorizationProcessing,
         analyticsService: AnalyticsProcessing,
         analyticsProvider: AnalyticsProviding,
         clientApplicationKey: String,
         gatewayId: String?,
         amount: Amount,
         savePaymentMethod: Bool?) {

        self.paymentService = paymentService
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider

        self.clientApplicationKey = clientApplicationKey
        self.gatewayId = gatewayId
        self.amount = amount
        self.savePaymentMethod = savePaymentMethod
    }
}

extension PaymentMethodsInteractor: PaymentMethodsInteractorInput {
    func fetchPaymentMethods() {

        let passportToken = authorizationService.getYandexToken()

        let paymentMethods = paymentService.fetchPaymentOptions(
            clientApplicationKey: clientApplicationKey,
            passportToken: passportToken,
            gatewayId: gatewayId,
            amount: amount.value.description,
            currency: amount.currency.rawValue,
            savePaymentMethod: savePaymentMethod
        )

        guard let output = output else { return }

        paymentMethods.done(output.didFetchPaymentMethods)
        paymentMethods.fail(output.didFetchPaymentMethods)
    }

    func getYandexDisplayName() -> String? {
        return authorizationService.getYandexDisplayName()
    }

    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }

    func makeTypeAnalyticsParameters() -> (authType: AnalyticsEvent.AuthType,
                                           tokenType: AnalyticsEvent.AuthTokenType?) {
        return analyticsProvider.makeTypeAnalyticsParameters()
    }
}
