import Foundation

struct CompoundValidator: Validator {

    private var validators: [Validator]

    init(validators: [Validator]) {
        self.validators = validators
    }

    mutating func append(_ validator: Validator) {
        validators.append(validator)
    }

    func validate(text: String) -> Bool {
        return validators.filter({ $0.validate(text: text) }).count == validators.count
    }
}
