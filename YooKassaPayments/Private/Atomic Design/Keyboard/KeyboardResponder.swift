import UIKit.UIView

/// An abstract interface for responding to and handling keyboard events.
protocol KeyboardResponder: AnyObject {
    /// The custom input accessory view to display when the receiver becomes the first responder.
    var inputAccessoryView: UIView? { get set }

    /// Updates the custom input and accessory views when the object is the first responder.
    func reloadInputViews()
}

extension UITextView: KeyboardResponder {}

extension UITextField: KeyboardResponder {}

extension UISearchBar: KeyboardResponder {}
