import Foundation

struct NonEmptyValidator: Validator {

    func validate(text: String) -> Bool {
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
