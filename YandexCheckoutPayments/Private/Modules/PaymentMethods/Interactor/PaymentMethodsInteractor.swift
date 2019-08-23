import Foundation
import struct YandexCheckoutPaymentsApi.MonetaryAmount

class PaymentMethodsInteractor {

    // MARK: - VIPER module

    weak var output: PaymentMethodsInteractorOutput?

    fileprivate let paymentService: PaymentProcessing
    fileprivate let authorizationService: AuthorizationProcessing
    fileprivate let analyticsService: AnalyticsProcessing
    fileprivate let analyticsProvider: AnalyticsProviding

    // MARK: - Data properties

    fileprivate let clientApplicationKey: String
    fileprivate let gatewayId: String?
    fileprivate let amount: Amount

    init(paymentService: PaymentProcessing,
         authorizationService: AuthorizationProcessing,
         analyticsService: AnalyticsProcessing,
         analyticsProvider: AnalyticsProviding,
         clientApplicationKey: String,
         gatewayId: String?,
         amount: Amount) {

        self.paymentService = paymentService
        self.authorizationService = authorizationService
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider

        self.clientApplicationKey = clientApplicationKey
        self.gatewayId = gatewayId
        self.amount = amount
    }
}

extension PaymentMethodsInteractor: PaymentMethodsInteractorInput {
    func fetchPaymentMethods() {

        let passportToken = authorizationService.getYandexToken()

        let paymentMethods = paymentService.fetchPaymentOptions(clientApplicationKey: clientApplicationKey,
                                                                passportToken: passportToken,
                                                                gatewayId: gatewayId,
                                                                amount: amount.value.description,
                                                                currency: amount.currency.rawValue)

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
