import class UIKit.UITextField

// MARK: - Styles

extension UITextField {
    enum Styles {

        /// Numeric style.
        /// Numeric keyboard; Center alignment.
        static let numeric = InternalStyle(name: "UITextField.numeric") { (textField: UITextField) in
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
        }

        /// Style with title3 font.
        static let title3 = InternalStyle(name: "UITextField.title3") { (textField: UITextField) in
            textField.font = .dynamicTitle3
        }
    }
}
