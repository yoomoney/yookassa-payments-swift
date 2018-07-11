import UIKit

final class TextInputTableViewCellPresenter {

    weak var view: TextInputTableViewCellInput?
    weak var output: TextInputTableViewCellModuleOutput?

    let inputStyle: InputPresenterStyle?
    let validator: Validator?
    let outputFormatter: Formatter?

    private lazy var textInputPresenter: InputPresenter? = {
        guard let style = inputStyle else { return nil }
        let inputPresenter = InputPresenter(textInputStyle: style)
        inputPresenter.output = view?.textControl
        return inputPresenter
    }()

    init(inputStyle: InputPresenterStyle? = nil,
         validator: Validator? = nil,
         outputFormatter: Formatter? = nil) {
        self.inputStyle = inputStyle
        self.validator = validator
        self.outputFormatter = outputFormatter
    }
}

extension TextInputTableViewCellPresenter: TextInputTableViewCellOutput {

}

// MARK: - TextControlDelegate
extension TextInputTableViewCellPresenter: TextControlDelegate {
    func textControl(_ textControl: TextControl,
                     shouldChangeTextIn range: NSRange,
                     replacementText text: String) -> Bool {

        textInputPresenter?.input(changeCharactersIn: range,
                                  replacementString: text,
                                  currentString: textControl.text ?? "")

        if let cell = view as? UITableViewCell {
            var outputText = textControl.text ?? ""
            if let formatter = outputFormatter {
                outputText = formatter.format(input: outputText) ?? ""
            }
            output?.textInput(cell: cell,
                              didChangeText: outputText,
                              valid: self.validator?.validate(text: textControl.text ?? "") ?? true)
        }

        return false
    }

    func textControlDidBeginEditing(_ textControl: TextControl) {
        view?.hideError()
        if !(view?.errorText?.isEmpty ?? true) {
            output?.needLayoutUpdate()
        }
    }

    func textControlDidEndEditing(_ textControl: TextControl) {
        if let validator = self.validator,
           !validator.validate(text: textControl.text ?? "") {
            view?.showError()
            if !(view?.errorText?.isEmpty ?? true) {
                output?.needLayoutUpdate()
            }
        }
    }
}
