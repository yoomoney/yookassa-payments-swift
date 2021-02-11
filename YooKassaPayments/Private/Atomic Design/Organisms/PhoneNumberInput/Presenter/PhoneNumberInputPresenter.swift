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

extension PhoneNumberInputPresenter: PhoneNumberInputInteractorOutput {}

// MARK: - PhoneNumberInputModuleInput

extension PhoneNumberInputPresenter: PhoneNumberInputModuleInput {
    func setValue(_ value: String) {
        phoneNumber = value
        view?.setValue(value)
    }

    func setPlaceholder(_ value: String) {
        view?.setPlaceholder(value)
    }

    func setTitle(_ value: String) {
        view?.setTitle(value)
    }

    func setSubtitle(_ value: String) {
        view?.setSubtitle(value)
    }

    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        interactor.isValidPhoneNumber(phoneNumber)
    }
}

// MARK: - Private helpers

private extension PhoneNumberInputPresenter {
    func validatePhoneNumber() {
        if interactor.isValidPhoneNumber(phoneNumber) {
            view?.markTextFieldValid(true)
            moduleOutput?.didChangePhoneNumber(phoneNumber)
        } else {
            moduleOutput?.didChangePhoneNumber("")
        }
    }
}
