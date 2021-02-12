import UIKit

extension UnderlinedTextField: InputView {
    var inputText: String? {
        get {
            textField.text
        }
        set {
            textField.text = newValue
        }
    }

    var beginningOfDocument: UITextPosition {
        textField.beginningOfDocument
    }

    var selectedTextRange: UITextRange? {
        get {
            textField.selectedTextRange
        }
        set {
            textField.selectedTextRange = newValue
        }
    }

    func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
        textField.offset(from: from, to: toPosition)
    }

    func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
        textField.position(from: position, offset: offset)
    }

    func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
        textField.textRange(from: fromPosition, to: toPosition)
    }
}
