struct NonEmptyValidator {}

// MARK: - Validator

extension NonEmptyValidator: Validator {
    func validate(text: String) -> Bool {
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
