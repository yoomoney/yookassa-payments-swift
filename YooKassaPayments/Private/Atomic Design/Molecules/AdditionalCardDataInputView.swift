/*
 * The MIT License (MIT)
 *
 * Copyright © 2020 NBCO YooMoney LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

protocol AdditionalCardDataInputViewDelegate: class {
    func additionalCardDataInputView(_ view: UIView,
                                     didChangeText text: String,
                                     inTextControl control: TextControl)
}

final class AdditionalCardDataInputView: UIView {

    private struct CscInputPresenterStyle: InputPresenterStyle {

        func removedFormatting(from string: String) -> String {
            return string.components(separatedBy: removeFormattingCharacterSet).joined()
        }

        func appendedFormatting(to string: String) -> String {
            return string.map { _ in "•" }.joined()
        }

        var maximalLength: Int {
            return 4
        }

        private let removeFormattingCharacterSet: CharacterSet = {
            var set = CharacterSet.decimalDigits
            set.insert(charactersIn: "•")
            return set.inverted
        }()
    }

    weak var delegate: AdditionalCardDataInputViewDelegate?

    // MARK: - UI properties

    var expiryDateHint: String? {
        didSet {
            expiryDateTextControl.topHint = expiryDateHint
            expiryDateTextControl.placeholder = expiryDateHint
        }
    }

    var cvcTextHint: String? {
        didSet {
            cvcTextControl.topHint = cvcTextHint
            cvcTextControl.placeholder = cvcTextHint
        }
    }

    var expiryDateControl: TextControl {
        return expiryDateTextControl
    }

    var cvcControl: TextControl {
        return cvcTextControl
    }

    // MARK: - Formatter components

    lazy var expiryDateInputPresenter: InputPresenter = {
        let expiryDateStyle = ExpiryDateInputPresenterStyle()
        let expiryDateInputPresenter = InputPresenter(textInputStyle: expiryDateStyle)
        expiryDateInputPresenter.output = expiryDateTextControl
        return expiryDateInputPresenter
    }()

    lazy var cvcTextInputPresenter: InputPresenter = {
        let cvcTextStyle = CscInputPresenterStyle()
        let cvcTextInputPresenter = InputPresenter(textInputStyle: cvcTextStyle)
        cvcTextInputPresenter.output = cvcTextControl
        return cvcTextInputPresenter
    }()

    // MARK: - Private UI properties

    private lazy var expiryDateTextControl: TextControl = {
        $0.delegate = self
        $0.setStyles(TextControl.Styles.cardDataInput,
                     TextControl.Styles.tintLine)
        return $0
    }(TextControl())

    private lazy var cvcTextControl: TextControl = {
        $0.delegate = self
        $0.setStyles(TextControl.Styles.cardDataInput,
                     TextControl.Styles.tintLine)
        return $0
    }(TextControl())

    // MARK: - Private logic helpers

    fileprivate var cachedCvc = ""

    // MARK: - Constraints

    private var activeConstraints: [NSLayoutConstraint] = []

    // MARK: - Initializers & deinitializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    deinit {
        unsubscribeFromNotifications()
    }

    // MARK: - Setup View

    private func setupView() {
        backgroundColor = .clear
        setupSubviews()
        setupConstraints()
        subscribeOnNotifications()
    }

    private func setupSubviews() {
        [
            expiryDateTextControl,
            cvcTextControl,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    private func setupConstraints() {

        if activeConstraints.isEmpty == false {
            NSLayoutConstraint.deactivate(activeConstraints)
        }

        let isAccessibilitySizeCategory = UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory
        if isAccessibilitySizeCategory == false {

            activeConstraints = [

                expiryDateTextControl.leading.constraint(equalTo: leading),
                expiryDateTextControl.top.constraint(equalTo: top),
                expiryDateTextControl.bottom.constraint(equalTo: bottom),
                expiryDateTextControl.width.constraint(equalTo: width, multiplier: 0.45),

                cvcTextControl.trailing.constraint(equalTo: trailing),
                cvcTextControl.top.constraint(equalTo: top),
                cvcTextControl.bottom.constraint(equalTo: bottom),
                cvcTextControl.width.constraint(equalTo: width, multiplier: 0.45),
            ]

        } else {

            activeConstraints = [

                expiryDateTextControl.leading.constraint(equalTo: leading),
                expiryDateTextControl.trailing.constraint(equalTo: trailing),
                expiryDateTextControl.top.constraint(equalTo: top),

                cvcTextControl.leading.constraint(equalTo: leading),
                cvcTextControl.trailing.constraint(equalTo: trailing),
                cvcTextControl.top.constraint(equalTo: expiryDateTextControl.bottom),
                cvcTextControl.bottom.constraint(equalTo: bottom),
            ]
        }

        NSLayoutConstraint.activate(activeConstraints)
    }

    // MARK: - Notifications

    private func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contentSizeCategoryDidChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func contentSizeCategoryDidChange() {
        setupConstraints()
    }
}

// MARK: - TextControlDelegate

extension AdditionalCardDataInputView: TextControlDelegate {
    func textControl(_ textControl: TextControl,
                     shouldChangeTextIn range: NSRange,
                     replacementText text: String) -> Bool {
        let inputPresenter: InputPresenter
        let resultText: String

        switch textControl {
        case expiryDateTextControl:
            inputPresenter = expiryDateInputPresenter
        case cvcTextControl:
            inputPresenter = cvcTextInputPresenter

            let replacementText = cachedCvc.count < inputPresenter.style.maximalLength ? text : ""
            let cvc = (cachedCvc as NSString).replacingCharacters(in: range, with: replacementText)
            cachedCvc = inputPresenter.style.removedFormatting(from: cvc)

        default:
            return false
        }
        inputPresenter.input(changeCharactersIn: range,
                             replacementString: text,
                             currentString: textControl.text ?? "")

        switch textControl {
        case expiryDateTextControl:
            resultText = inputPresenter.style.removedFormatting(from: textControl.text ?? "")
        case cvcTextControl:
            resultText = cachedCvc
        default:
            return false
        }

        delegate?.additionalCardDataInputView(self, didChangeText: resultText, inTextControl: textControl)
        return false
    }
}
