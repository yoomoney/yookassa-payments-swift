protocol PhoneNumberInputViewOutput: class {
    func phoneNumberDidChange(on phoneNumber: String)
    func didFinishChangePhoneNumber()
}

protocol PhoneNumberInputViewInput: class {
    func setValue(_ value: String)
    func setPlaceholder(_ value: String)
    func setTitle(_ value: String)
    func setSubtitle(_ value: String)
    func markTextFieldValid(_ isValid: Bool)
}
