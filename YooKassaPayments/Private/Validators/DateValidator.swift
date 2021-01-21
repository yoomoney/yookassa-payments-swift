struct DateValidator {

    // MARK: - Init data

    let min: Date?
    let max: Date?
    let formatter: DateFormatter

    // MARK: - Init

    init(
        formatter: DateFormatter,
        min: Date?,
        max: Date?
    ) {
        self.formatter = formatter
        self.max = max
        self.min = min
    }
}

// MARK: - Validator

extension DateValidator: Validator {
    func validate(text: String) -> Bool {

        guard let date = formatter.date(from: text) else {
            return false
        }

        if let min = self.min, date < min {
            return false
        }

        if let max = self.max, date > max {
            return false
        }

        return true
    }
}
