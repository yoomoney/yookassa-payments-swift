import UIKit

/// Style for keyboard view
struct KeyboardViewStyle {

    /// Width of separator line
    let separatorLineWidth: CGFloat

    /// Color of separatore line
    let separatorLineColor: UIColor

    /// Button style applied to keyboard number buttons
    let numberButtonStyle: KeyboardButtonStyle

    /// Default constructor
    ///
    /// - Parameters:
    ///   - separatorLineWidth: Width of separator line
    ///   - separatorLineColor: Color of separatore line
    ///   - numberButtonStyle: Button style applied to keyboard number buttons
    init(
        separatorLineWidth: CGFloat = 0,
        separatorLineColor: UIColor = .clear,
        numberButtonStyle: KeyboardButtonStyle = KeyboardButtonStyle()
    ) {
        self.separatorLineWidth = separatorLineWidth
        self.separatorLineColor = separatorLineColor
        self.numberButtonStyle = numberButtonStyle
    }
}
