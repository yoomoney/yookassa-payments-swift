/// Class for handle open url.
public final class YKSdk {
    
    /// Input for payment methods module.
    weak var paymentMethodsModuleInput: PaymentMethodsModuleInput?
    
    /// Output for tokenization module.
    weak var moduleOutput: TokenizationModuleOutput?
    
    /// Application scheme for returning after opening a deeplink.
    var applicationScheme: String?
    
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
    
        case .yooMoneyExchange(let cryptogram):
            paymentMethodType = nil
            paymentMethodsModuleInput?.authorizeInYooMoney(with: cryptogram)
        }
        
        if let paymentMethodType = paymentMethodType {
            moduleOutput?.didSuccessfullyConfirmation(paymentMethodType: paymentMethodType)
            return true
        } else {
            return false
        }
    }
}
