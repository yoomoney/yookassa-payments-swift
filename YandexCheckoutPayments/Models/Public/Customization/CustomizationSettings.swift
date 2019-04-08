import UIKit

/// Settings to customize SDK interface.
public struct CustomizationSettings {

    /// Scheme to customize main interface, like,
    /// submit buttons, switches, text inputs.
    public let mainScheme: UIColor

    /// Creates instance of `CustomizationSettings`.
    ///
    /// - Parameters:
    ///     - mainScheme: Scheme to customize main interface, like,
    ///                   submit buttons, switches, text inputs.
    public init(mainScheme: UIColor = CustomizationColors.blueRibbon) {
        self.mainScheme = mainScheme
    }
}
