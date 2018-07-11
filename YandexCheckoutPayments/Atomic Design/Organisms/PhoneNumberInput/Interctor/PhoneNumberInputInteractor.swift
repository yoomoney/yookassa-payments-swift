final class PhoneNumberInputInteractor {

    // MARK: - VIPER properties

    var formatter: PhoneNumberFormatter

    weak var output: PhoneNumberInputInteractorOutput?

    // MARK: - Initializers

    init(formatter: PhoneNumberFormatter) {
        self.formatter = formatter
    }
}

extension PhoneNumberInputInteractor: PhoneNumberInputInteractorInput {
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        if phoneNumber.count == formatter.countryCodeLength + formatter.phoneMaxLength {
            return true
        } else {
            return false
        }
    }
}
