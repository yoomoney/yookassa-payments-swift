import UIKit

/// Style for keyboard button view
struct KeyboardButtonStyle {

    /// Highlighted Type for keyboard button view
    enum HighlightedType {
        case fill
        case circle
    }

    /// Background color for normal button state
    let backgroundColor: UIColor

    /// Background color for highlighted button state
    let highlightedColor: UIColor

    /// Text color for normal button state
    let textColor: UIColor

    /// Text color for selected button state
    let selectedTextColor: UIColor

    /// Text color for highlighted button state
    let highlightedTextColor: UIColor

    /// Highlighted Type for button state
    let highlightedType: HighlightedType

    /// Button font
    let font: UIFont

    /// Default constructor
    ///
    /// - Parameters:
    ///   - backgroundColor: Background color for normal button state
    ///   - highlightedColor: Background color for highlighted button state
    ///   - textColor: Text color for normal button state
    ///   - selectedTextColor: Text color for selected button state
    ///   - highlightedTextColor: Text color for highlighted button state
    ///   - font: Button font
    init(backgroundColor: UIColor = .clear,
         highlightedColor: UIColor = .clear,
         textColor: UIColor = .clear,
         selectedTextColor: UIColor = .clear,
         highlightedTextColor: UIColor = .clear,
         highlightedType: HighlightedType = .circle,
         font: UIFont = .systemFont(ofSize: 20)) {
        self.backgroundColor = backgroundColor
        self.highlightedColor = highlightedColor
        self.textColor = textColor
        self.selectedTextColor = selectedTextColor
        self.highlightedTextColor = highlightedTextColor
        self.highlightedType = highlightedType
        self.font = font
    }
}
