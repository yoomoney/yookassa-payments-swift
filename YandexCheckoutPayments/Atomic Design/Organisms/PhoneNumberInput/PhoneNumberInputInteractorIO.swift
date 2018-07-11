protocol PhoneNumberInputInteractorOutput: class {
}

protocol PhoneNumberInputInteractorInput: class {
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool
}
