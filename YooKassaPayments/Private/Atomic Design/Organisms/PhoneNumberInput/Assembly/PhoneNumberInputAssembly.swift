import UIKit

enum PhoneNumberInputAssembly {
    static func makeModule(
        moduleOutput: PhoneNumberInputModuleOutput?
    ) -> (PhoneNumberInputView, PhoneNumberInputModuleInput) {
        let view = PhoneNumberInputView()

        let formatter = PhoneNumberFormatterAssembly.makeFormatter()
        let textInputStyle = PhoneNumberStyleWithAutoCorrection(
            phoneNumberFormatter: formatter
        )

        let presenter = PhoneNumberInputPresenter()
        let interactor = PhoneNumberInputInteractor(
            formatter: formatter
        )

        view.textInputStyle = textInputStyle
        view.output = presenter

        presenter.view = view
        presenter.moduleOutput = moduleOutput
        presenter.interactor = interactor

        interactor.output = presenter

        return (view, presenter)
    }
}
