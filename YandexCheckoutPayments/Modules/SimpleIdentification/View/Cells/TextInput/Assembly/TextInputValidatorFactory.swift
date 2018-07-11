import Foundation

enum TextInputValidatorFactory {

    static func makeValidator(_ item: TextInputDisplayItem) -> Validator? {
        var result = CompoundValidator(validators: [])

        switch item.type {

        case .text(let pattern, let minLenght, let maxlength):
            if let pattern = pattern,
               let validator = RegexValidator(pattern: pattern) {
                result.append(validator)
            }

            if let max = maxlength {
                let min = minLenght ?? 0
                let lenghtValidator = LenghtValidator(range: min...max)
                result.append(lenghtValidator)
            }

        case .email:
            result.append(EmailValidator())

        case .phone:
            break

        case .date(let format, let min, let max):
            switch format {
            case .date:
                result.append(DateValidator(formatter: DateFactory.dateInputFormatter, min: min, max: max))
            case .month:
                result.append(DateValidator(formatter: DateFactory.monthInputFormatter, min: min, max: max))
            }
        }

        if item.isRequired {
            result.append(NonEmptyValidator())
        }

        return result
    }
}
