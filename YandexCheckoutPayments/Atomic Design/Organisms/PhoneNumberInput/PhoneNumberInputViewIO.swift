protocol PhoneNumberInputViewOutput: class {
    func phoneNumberDidChange(on phoneNumber: String)
    func didFinishChangePhoneNumber()
}

protocol PhoneNumberInputViewInput: class {
    func setPlaceholder(_ placeholder: String)
    func setHint(_ hint: String)
    func setValue(_ value: String)
    func markTextFieldValid(_ isValid: Bool)
}
