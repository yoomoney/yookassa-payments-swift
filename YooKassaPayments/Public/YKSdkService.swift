/// Class for handle open url.
public final class YKSdk {
    
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
        
        switch deeplink {
        case .yooMoneyApp2App:
            // TODO: - Handle deeplink https://jira.yamoney.ru/browse/MOC-1812
            break
            
        default:
            assertionFailure("Unsupported deeplink \(deeplink)")
        }
        
        return false
    }
}
