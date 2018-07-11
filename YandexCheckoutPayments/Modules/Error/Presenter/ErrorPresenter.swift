import UIKit.UIImage

final class ErrorPresenter {

    // MARK: - VIPER module properties

    weak var view: ErrorViewInput?
    weak var moduleOutput: ErrorModuleOutput?

    // MARK: - Module Data

    fileprivate let inputData: ErrorModuleInputData

    init(inputData: ErrorModuleInputData) {
        self.inputData = inputData
    }
}

// MARK: - ErrorViewOutput

extension ErrorPresenter: ErrorViewOutput {

    func setupView() {
        guard let view = view else { return }
        view.showPlaceholder(message: inputData.errorTitle)
    }
}

// MARK: - ActionTextDialogDelegate

extension ErrorPresenter: ActionTextDialogDelegate {

    func didPressButton() {
        moduleOutput?.didPressPlaceholderButton(on: self)
    }
}

// MARK: - ErrorModuleInput

extension ErrorPresenter: ErrorModuleInput {}
