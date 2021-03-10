import UIKit

extension UnderlinedTextField {
    enum Styles {
        static let `default` = InternalStyle(name: "UnderlinedTextField.default") { (view: UnderlinedTextField) in
            view.textField.setStyles(UITextField.Styles.default)
        }

        /// Phone style.
        /// Phone keyboard; Text content type phone number.
        static let phone = InternalStyle(name: "UnderlinedTextField.numeric") { (view: UnderlinedTextField) in
            view.textField.setStyles(UITextField.Styles.phone)
        }
    }
}
