import UIKit

struct TextInputDisplayItem {
    let title: String?
    var value: String?
    let hint: String?
    let isEnabled: Bool
    let isRequired: Bool
    let errorText: String?
    let name: String

    let type: InputType
    let keyboardType: UIKeyboardType

    enum InputType {
        case phone
        case email
        case text(pattern: String?, minLenght: Int?, maxlength: Int?)
        case date(format: DateFormat, min: Date?, max: Date?)
    }

    enum DateFormat {
        case date
        case month
    }
}
