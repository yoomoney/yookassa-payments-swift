protocol PhoneNumberInputModuleInput: AnyObject {
    func setValue(
        _ value: String
    )
    func setPlaceholder(
        _ value: String
    )
    func setTitle(
        _ value: String
    )
    func setSubtitle(
        _ value: String
    )
}

protocol PhoneNumberInputModuleOutput: AnyObject {
    func didChangePhoneNumber(
        _ phoneNumber: String
    )
}
