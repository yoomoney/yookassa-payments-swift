/// Class for handle open url.
public final class YKSdk {
    
    /// Output for tokenization module.
    weak var moduleOutput: TokenizationModuleOutput?
    
    /// Application scheme for returning after opening a deeplink.
    var applicationScheme: String?

    var analyticsService: AnalyticsService?
    
    private init() {}
    
    /// Shared YooKassa sdk service.
    public static let shared = YKSdk()
    
    public func hanleOpen(
        url: URL,
        sourceApplication: String?
    ) -> Bool {
        guard let scheme = url.scheme,
              let applicationScheme = applicationScheme,
              "\(scheme)://" == applicationScheme,
              let deeplink = DeepLinkFactory.makeDeepLink(url: url) else {
            return false
        }
        
        let paymentMethodType: PaymentMethodType?
        
        switch deeplink {
        case .invoicingSberpay:
            paymentMethodType = .sberbank
            
        default:
            assertionFailure("Unsupported deeplink \(deeplink)")
            paymentMethodType = nil
        }
        
        if let paymentMethodType = paymentMethodType {
            let event: AnalyticsEvent = .actionSberPayConfirmation(
                sberPayConfirmationStatus: .success,
                sdkVersion: Bundle.frameworkVersion
            )
            analyticsService?.trackEvent(event)
            moduleOutput?.didSuccessfullyConfirmation(paymentMethodType: paymentMethodType)
            return true
        } else {
            return false
        }
    }
}
