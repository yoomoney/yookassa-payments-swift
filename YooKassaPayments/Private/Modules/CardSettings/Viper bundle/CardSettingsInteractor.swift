import Foundation

class CardSettingsInteractor: CardSettingsInteractorInput {
    var output: CardSettingsInteractorOutput!

    private let analyticsService: AnalyticsTracking
    private let paymentService: PaymentService
    private let clientId: String

    init(clientId: String, paymentService: PaymentService, analyticsService: AnalyticsTracking) {
        self.analyticsService = analyticsService
        self.clientId = clientId
        self.paymentService = paymentService
    }

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }

    func unbind(id: String) {
        paymentService.unbind(authToken: clientId, id: id) { [weak self] in
            guard let self = self else { return }
            switch $0 {
            case .failure(let error):
                self.output.didFailUnbind(error: error, id: id)
            case .success:
                self.output.didUnbind(id: id)
            }
        }
    }
}
