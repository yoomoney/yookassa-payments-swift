/// Class for handle open url.
public final class ConfirmationService {
    
    /// Output for tokenization module.
    weak var moduleOutput: TokenizationModuleOutput?
    
    private init() {}
    
    /// Shared confirmation service.
    public static let shared = ConfirmationService()
    
    public func hanleOpen(
        url: URL,
        sourceApplication: String?
    ) -> Bool {
        // TODO: - Handle open deeplink https://jira.yamoney.ru/browse/MOC-1758
        return true
    }
}
