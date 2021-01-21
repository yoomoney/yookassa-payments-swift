struct LenghtValidator {

    // MARK: - Init data

    let range: ClosedRange<Int>

    // MARK: - Init

    init(range: ClosedRange<Int>) {
        self.range = range
    }
}

// MARK: - Validator

extension LenghtValidator: Validator {
    func validate(text: String) -> Bool {
        return range ~= text.count
    }
}
