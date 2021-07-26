protocol PhoneNumberInputInteractorOutput: AnyObject {
}

protocol PhoneNumberInputInteractorInput: AnyObject {
    func isValidPhoneNumber(_ phoneNumber: String) -> Bool
}
