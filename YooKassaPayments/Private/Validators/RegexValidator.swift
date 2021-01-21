struct RegexValidator {

    // MARK: - Init data

    let expression: NSRegularExpression

    // MARK: - Init

    init?(pattern: String) {
        do {
            self.expression = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return nil
        }
    }
}

// MARK: - Validator

extension RegexValidator: Validator {
    func validate(text: String) -> Bool {
        let matches = expression.matches(
            in: text,
            options: [],
            range: NSRange(location: 0, length: text.count)
        )
        return matches.isEmpty == false
    }
}
