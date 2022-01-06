/// Class for handle open url.
public final class YKSdk {

    /// Input for payment methods module.
    weak var paymentMethodsModuleInput: PaymentMethodsModuleInput?

    /// Output for tokenization module.
    weak var moduleOutput: TokenizationModuleOutput?

    /// Application scheme for returning after opening a deeplink.
    var applicationScheme: String?

    var analyticsTracking: AnalyticsTracking!
    var analyticsContext: AnalyticsEventContext!

    private init() {}

    /// Shared YooKassa sdk service.
    public static let shared = YKSdk()

    /// Open a resource specified by a URL.
    public func handleOpen(
        url: URL,
        sourceApplication: String?
    ) -> Bool {
        guard let scheme = url.scheme,
              let applicationScheme = applicationScheme,
              "\(scheme)://" == applicationScheme,
              let deeplink = DeepLinkFactory.makeDeepLink(url: url) else {
            return false
        }

        switch deeplink {
        case .invoicingSberpay:
            analyticsTracking.track(event: .actionSberPayConfirmation(success: true))
            moduleOutput?.didSuccessfullyConfirmation(paymentMethodType: .sberbank)

        case .yooMoneyExchange(let cryptogram):
            paymentMethodsModuleInput?.authorizeInYooMoney(with: cryptogram)
        }

        return true
    }
}
