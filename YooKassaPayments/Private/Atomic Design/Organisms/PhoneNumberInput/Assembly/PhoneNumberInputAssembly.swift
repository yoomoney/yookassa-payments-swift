import UIKit

enum PhoneNumberInputAssembly {
    static func makeModule(
        moduleOutput: PhoneNumberInputModuleOutput?
    ) -> (UIViewController, PhoneNumberInputModuleInput) {
        let viewController = PhoneNumberInputViewController()

        let formatter = PhoneNumberFormatterAssembly.makeFormatter()
        let textInputStyle = PhoneNumberStyleWithAutoCorrection(phoneNumberFormatter: formatter)

        let presenter = PhoneNumberInputPresenter()
        let interactor = PhoneNumberInputInteractor(formatter: formatter)

        viewController.textInputStyle = textInputStyle
        viewController.output = presenter

        presenter.view = viewController
        presenter.moduleOutput = moduleOutput
        presenter.interactor = interactor

        interactor.output = presenter

        return (viewController, presenter)
    }
}
