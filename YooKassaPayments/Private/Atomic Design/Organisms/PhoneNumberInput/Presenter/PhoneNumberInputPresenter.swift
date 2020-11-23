final class PhoneNumberInputPresenter {

    // MARK: - VIPER properties

    weak var view: PhoneNumberInputViewInput?
    weak var moduleOutput: PhoneNumberInputModuleOutput?
    var interactor: PhoneNumberInputInteractorInput!

    // MARK: - Data

    fileprivate var phoneNumber = ""
}

// MARK: - PhoneNumberInputViewOutput

extension PhoneNumberInputPresenter: PhoneNumberInputViewOutput {
    func phoneNumberDidChange(on phoneNumber: String) {
        self.phoneNumber = phoneNumber
        validatePhoneNumber()
    }

    func didFinishChangePhoneNumber() {
        if interactor.isValidPhoneNumber(phoneNumber) == false {
            view?.markTextFieldValid(false)
        }
    }
}

// MARK: - PhoneNumberInputInteractorOutput

extension PhoneNumberInputPresenter: PhoneNumberInputInteractorOutput {
}

// MARK: - PhoneNumberInputModuleInput

extension PhoneNumberInputPresenter: PhoneNumberInputModuleInput {
    func setPlaceholder(_ placeholder: String) {
        view?.setPlaceholder(placeholder)
    }

    func setHint(_ hint: String) {
        view?.setHint(hint)
    }

    func setValue(_ value: String) {
        phoneNumber = value
        view?.setValue(value)
    }

    func validatePhoneNumber() {
        if interactor.isValidPhoneNumber(phoneNumber) {
            view?.markTextFieldValid(true)
            moduleOutput?.didChangePhoneNumber(phoneNumber)
        } else {
            moduleOutput?.didChangePhoneNumber("")
        }
    }

}
