/// Class for handle open url.
public final class ConfirmationService {
    
    /// Output for tokenization module.
    weak var moduleOutput: TokenizationModuleOutput?
    
    /// Application scheme for returning after opening a deeplink.
    var applicationScheme: String?
    
    private init() {}
    
    /// Shared confirmation service.
    public static let shared = ConfirmationService()
    
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
            moduleOutput?.didSuccessfullyConfirmation(paymentMethodType: paymentMethodType)
            return true
        } else {
            return false
        }
    }
}
