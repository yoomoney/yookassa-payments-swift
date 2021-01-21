final class PhoneNumberInputInteractor {

    // MARK: - VIPER

    weak var output: PhoneNumberInputInteractorOutput?

    // MARK: - Init data

    var formatter: PhoneNumberFormatter

    // MARK: - Init

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
