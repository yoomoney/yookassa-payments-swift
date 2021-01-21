struct CompoundValidator {

    // MARK: - Init data

    private var validators: [Validator]

    // MARK: - Init

    init(validators: [Validator]) {
        self.validators = validators
    }

    mutating func append(_ validator: Validator) {
        validators.append(validator)
    }
}

// MARK: - Validator

extension CompoundValidator: Validator {
    func validate(text: String) -> Bool {
        return validators
            .filter({ $0.validate(text: text) })
            .count == validators.count
    }
}
