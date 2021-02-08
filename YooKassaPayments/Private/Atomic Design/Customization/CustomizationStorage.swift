/// Class for storing customization settings.
final class CustomizationStorage {
    
    /// Stored scheme to customize main interface, like,
    /// submit buttons, switches, text inputs.
    var mainScheme: UIColor = .blueRibbon
    
    private init() {}
    
    /// Shared customization settings storage.
    static let shared = CustomizationStorage()
}
