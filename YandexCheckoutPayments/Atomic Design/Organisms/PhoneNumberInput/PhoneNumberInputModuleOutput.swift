protocol PhoneNumberInputModuleInput: class {
    func setPlaceholder(_ placeholder: String)
    func setHint(_ hint: String)
    func setValue(_ value: String)
}

protocol PhoneNumberInputModuleOutput: class {
    func didChangePhoneNumber(_ phoneNumber: String)
}
