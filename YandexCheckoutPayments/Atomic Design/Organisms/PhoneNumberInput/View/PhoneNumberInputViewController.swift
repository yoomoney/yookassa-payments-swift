import Foundation
import UIKit

final class PhoneNumberInputViewController: UIViewController {

    // MARK: - Viper properties

    var output: PhoneNumberInputViewOutput!

    // MARK: - UI properties

    fileprivate lazy var textControl: TextControl = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setStyles(TextControl.Styles.`default`,
                     TextControl.Styles.cardDataInput)
        $0.delegate = self
        return $0
    }(TextControl())

    fileprivate lazy var inputPresenter: InputPresenter = {
        $0.output = textControl
        return $0
    }(InputPresenter(textInputStyle: textInputStyle))

    var textInputStyle: InputPresenterStyle!

    fileprivate lazy var identifyCountryService = IdentifyCountryService()

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.defaultBackground)
        view.restorationIdentifier = Constants.restorationIdentifier
        loadSubviews()
        loadConstraints()
    }

    private func loadSubviews() {
        view.addSubview(textControl)
    }

    private func loadConstraints() {
        let constraints = [
            textControl.leading.constraint(equalTo: view.leading),
            textControl.trailing.constraint(equalTo: view.trailing),
            textControl.top.constraint(equalTo: view.top),
            textControl.bottom.constraint(equalTo: view.bottom),
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - PhoneNumberInputViewInput

extension PhoneNumberInputViewController: PhoneNumberInputViewInput {
    func markTextFieldValid(_ isValid: Bool) {
        textControl.state = isValid ? .normal : .error
    }

    func setPlaceholder(_ placeholder: String) {
        textControl.placeholder = placeholder
        textControl.topHint = placeholder
    }

    func setHint(_ hint: String) {
        textControl.set(bottomHintText: hint, for: .normal)
    }

    func setValue(_ value: String) {
        textControl.text = textInputStyle.appendedFormatting(to: value)
    }
}

// MARK: - TextControlDelegate

extension PhoneNumberInputViewController: TextControlDelegate {
    func textControlDidBeginEditing(_ textControl: TextControl) { }

    func textControlDidEndEditing(_ textControl: TextControl) {
        output.didFinishChangePhoneNumber()
    }

    func textControl(_ textControl: TextControl,
                     shouldChangeTextIn range: NSRange,
                     replacementText text: String) -> Bool {
        inputPresenter.input(changeCharactersIn: range, replacementString: text, currentString: textControl.text ?? "")

        output.phoneNumberDidChange(on: textInputStyle.removedFormatting(from: textControl.text ?? ""))

        return false
    }

    func textControlDidChange(_ textControl: TextControl) { }

    func didPressRightButton(on textControl: TextControl) { }
}

// MARK: - Constants

extension PhoneNumberInputViewController {
    fileprivate enum Constants {
        static let restorationIdentifier = "PhoneNumberInputView"
    }
}
