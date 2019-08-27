/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2017 NBCO Yandex.Money LLC
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

import FunctionalSwift
import UIKit

///// Base view to enter bank card pan, expiry date, cvv
class BankCardDataInputViewController: UIViewController, PlaceholderProvider {

    // MARK: - Viper properties

    var output: BankCardDataInputViewOutput!

    // UI properties

    fileprivate lazy var scrollViewController: ScrollViewController = {
        $0.view.translatesAutoresizingMaskIntoConstraints = false
        $0.scrollView.keyboardDismissMode = .none
        $0.footerInsets = UIEdgeInsets(top: 0, left: Space.double, bottom: Space.double, right: Space.double)
        if #available (iOS 11.0, *) {
            $0.scrollView.contentInsetAdjustmentBehavior = .always
        }
        return $0
    }(ScrollViewController())

    fileprivate lazy var panInputTextControl: TextControl = {
        $0.delegate = self
        $0.setStyles(TextControl.Styles.cardDataInput,
                     TextControl.Styles.leftIconVisible,
                     TextControl.Styles.tintLine)
        return $0
    }(TextControl())

    fileprivate lazy var additionalCardDataInputView: AdditionalCardDataInputView = {
        $0.delegate = self
        return $0
    }(AdditionalCardDataInputView())

    fileprivate lazy var confirmButton: Button = {
        $0.setStyles(UIButton.DynamicStyle.primary)
        $0.addTarget(self, action: #selector(confirmButtonDidPress), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(Button(type: .custom))

    fileprivate lazy var contentView: UIView = {
        $0.setStyles(UIView.Styles.grayBackground)
        return $0
    }(UIView())

    fileprivate lazy var closeBarButtonItem = UIBarButtonItem(image: UIImage.named("Common.close"),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(closeBarButtonItemDidPress))

    fileprivate var scrollView: UIScrollView {
        return scrollViewController.scrollView
    }

    fileprivate var activityIndicatorView: ActivityIndicatorView?

    // MARK: - Constraints

    fileprivate lazy var contentViewTopConstraintToScrollView: NSLayoutConstraint = {
        self.contentView.top.constraint(equalTo: scrollView.top)
    }()

    fileprivate lazy var contentViewTopConstraintToView: NSLayoutConstraint = {
        self.contentView.top.constraint(equalTo: view.topMargin, constant: 96)
    }()

    // MARK: - Formatter components

    var panPresenter: InputPresenter! {
        didSet {
            panPresenter.output = panInputTextControl
        }
    }

    // MARK: - PlaceholderProvider

    lazy var placeholderView: PlaceholderView = {
        $0.setStyles(UIView.Styles.defaultBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentView = self.actionTextDialog
        return $0
    }(PlaceholderView())

    lazy var actionTextDialog: ActionTextDialog = {
        $0.setStyles(ActionTextDialog.Styles.fail, ActionTextDialog.Styles.light)
        $0.buttonTitle = §Localized.PlaceholderView.buttonTitle
        $0.delegate = self.output
        return $0
    }(ActionTextDialog())

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.grayBackground)
        addChild(scrollViewController)
        setupView()
        scrollViewController.didMove(toParent: self)
    }

    // MARK: - Responding to View Events

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
        navigationItem.leftBarButtonItem = closeBarButtonItem
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        output.viewDidAppear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        output.viewDidDisappear()
    }
}

// MARK: - Presentable

extension BankCardDataInputViewController: Presentable {
    var iPhonePresentationStyle: PresentationStyle {
        return .modal
    }

    var iPadPresentationStyle: PresentationStyle {
        return .pageSheet
    }

    var hasNavigationBar: Bool {
        return true
    }
}

// MARK: - BankCardDataInputViewInput

extension BankCardDataInputViewController: BankCardDataInputViewInput {
    func setNavigationBarTitle(_ title: String) {
        navigationItem.title = title
    }

    func setPanInputTextControlHint(_ hint: String) {
        panInputTextControl.topHint = hint
        panInputTextControl.placeholder = hint
    }

    func setExpiryDateTextControlHint(_ hint: String) {
        additionalCardDataInputView.expiryDateHint = hint
    }

    func setPanInputTextControlValue(_ value: String) {
        panInputTextControl.text = panPresenter?.style.appendedFormatting(to: value) ?? value
    }

    func setExpiryDateTextControlValue(_ value: String) {
        let formattedValue = additionalCardDataInputView.expiryDateInputPresenter.style.appendedFormatting(to: value)
        additionalCardDataInputView.expiryDateControl.text = formattedValue
    }

    func setExpiryDateTextControlFormattedValue(_ value: String) {
        additionalCardDataInputView.expiryDateControl.text = value
    }

    func setPanInputTextControlIsEnabled(_ isEnabled: Bool) {
        panInputTextControl.isUserInteractionEnabled = isEnabled
    }

    func setExpiryDateTextControlIsEnabled(_ isEnabled: Bool) {
        additionalCardDataInputView.expiryDateControl.isUserInteractionEnabled = isEnabled
    }

    func setPanInputTextControlDisabledStyle() {
        panInputTextControl.setStyles(TextControl.Styles.linkedCardDataInput, TextControl.Styles.leftIconVisible)
    }

    func setExpiryDateTextControlDisabledStyle() {
        additionalCardDataInputView.expiryDateControl.setStyles(TextControl.Styles.linkedCardDataInput)
    }

    func setCvcTextControlHint(_ hint: String) {
        additionalCardDataInputView.cvcTextHint = hint
    }

    func setConfirmButtonEnabled(_ isEnabled: Bool) {
        confirmButton.isEnabled = isEnabled
    }

    func setPanIsValid(_ isValid: Bool) {
        panInputTextControl.state = isValid ? .normal : .error
    }

    func setExpiryDateIsValid(_ isValid: Bool) {
        additionalCardDataInputView.expiryDateControl.state = isValid ? .normal : .error
    }

    func setConfirmButtonTitle(_ title: String) {
        confirmButton.setStyledTitle(title, for: .normal)
    }

    func endEditing(_ force: Bool) {
        view.endEditing(force)
    }

    func showPlaceholder(message: String) {
        actionTextDialog.title = message
        showPlaceholder()
    }

    func setPanInputScanModeIsEnabled(_ isEnabled: Bool) {
        isEnabled
            ? panInputTextControl.appendStyle(TextControl.Styles.cardDataInputWithScan)
            : panInputTextControl.appendStyle(TextControl.Styles.cardDataInputWithoutScan)
    }

    func setBankLogoImage(_ image: UIImage) {
        panInputTextControl.leftIcon.image = image
            .scaled(to: CGSize(width: 24, height: 24))
    }

    var focus: BankCardFocus? {
        get {
            return [BankCardFocus.pan, .expiryDate, .csc].first { $0.textControl(in: self).isFirstResponder }
        }
        set {
            if let newValue = newValue {
                _ = newValue.textControl(in: self).becomeFirstResponder()
            } else {
                _ = focus?.textControl(in: self).resignFirstResponder()
            }
        }
    }

    func showActivity() {
        guard self.activityIndicatorView == nil else { return }
        let activityIndicatorView = ActivityIndicatorView()
        activityIndicatorView.setStyles(ActivityIndicatorView.Styles.heavyLight)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.frame = view.bounds
        let constraints = [
            activityIndicatorView.left.constraint(equalTo: view.left),
            activityIndicatorView.right.constraint(equalTo: view.right),
            activityIndicatorView.top.constraint(equalTo: view.top),
            activityIndicatorView.bottom.constraint(equalTo: view.bottom),
        ]
        NSLayoutConstraint.activate(constraints)
        activityIndicatorView.layoutIfNeeded()
        activityIndicatorView.activity.startAnimating()

        self.activityIndicatorView = activityIndicatorView
    }

    func hideActivity() {
        activityIndicatorView?.removeFromSuperview()
        activityIndicatorView = nil
    }
}

// MARK: - Actions

extension BankCardDataInputViewController {
    @objc
    func confirmButtonDidPress() {
        output.confirmButtonDidPress()
    }

    @objc
    func closeBarButtonItemDidPress() {
        output.closeBarButtonItemDidPress()
    }
}

// MARK: - AdditionalCardDataInputViewDelegate

extension BankCardDataInputViewController: AdditionalCardDataInputViewDelegate {
    func additionalCardDataInputView(_ view: UIView, didChangeText text: String, inTextControl control: TextControl) {
        switch control {
        case additionalCardDataInputView.expiryDateControl:
            output.didSetExpiryDate(text)
        case additionalCardDataInputView.cvcControl:
            output.didSetCsc(text)
        default:
            break
        }
    }
}

// MARK: - TextControlDelegate

extension BankCardDataInputViewController: TextControlDelegate {
    func textControl(_ textControl: TextControl,
                     shouldChangeTextIn range: NSRange,
                     replacementText text: String) -> Bool {
        let inputPresenter: InputPresenter
        let outputDidSet: (String) -> Void
        switch textControl {
        case panInputTextControl:
            inputPresenter = panPresenter
            outputDidSet = output.didSetPan
        default:
            return false
        }
        inputPresenter.input(changeCharactersIn: range,
                             replacementString: text,
                             currentString: textControl.text ?? "")
        let text = inputPresenter.style.removedFormatting(from: textControl.text ?? "")
        outputDidSet(text)
        return false
    }

    func didPressRightButton(on textControl: TextControl) {
        output?.didPressScanButton()
    }
}

// MARK: - PlaceholderPresenting

extension BankCardDataInputViewController {
    func showPlaceholder() {
        scrollViewController.footerView = nil
        contentViewTopConstraintToScrollView.isActive = false
        contentViewTopConstraintToView.isActive = true
        showPlaceholder(on: contentView)
    }

    func hidePlaceholder() {
        contentViewTopConstraintToView.isActive = false
        contentViewTopConstraintToScrollView.isActive = true
        placeholderView.removeFromSuperview()
    }
}

// MARK: - Localized

private extension BankCardDataInputViewController {
    enum Localized {

        enum PlaceholderView: String {
            case buttonTitle = "Common.PlaceholderView.buttonTitle"
        }
    }
}

// MARK: - Setup view

private extension BankCardDataInputViewController {
    func setupView() {
        setupNavigationItem()
        setupSubviews()
        setupConstraints()
    }

    func setupNavigationItem() {
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .always
        }
    }

    func setupSubviews() {
        view.addSubview(scrollViewController.view)
        scrollView.addSubview(contentView)

        scrollViewController.footerView = confirmButton

        let subviews: [UIView] = [
            panInputTextControl,
            additionalCardDataInputView,
        ]

        contentView.addSubview <^> subviews
    }

    func setupConstraints() {
        [
            contentView,
            panInputTextControl,
            additionalCardDataInputView,
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        var constraints: [NSLayoutConstraint] = []

        contentViewTopConstraintToView.isActive = false

        constraints += [
            contentViewTopConstraintToScrollView,
            contentView.leading.constraint(equalTo: scrollView.leading, constant: Space.double),
            scrollView.trailing.constraint(equalTo: contentView.trailing, constant: Space.double),
            scrollView.bottom.constraint(equalTo: contentView.bottom, constant: Space.double),
            contentView.width.constraint(equalTo: view.width, constant: -(Space.double * 2)),

            panInputTextControl.top.constraint(equalTo: contentView.top),
            panInputTextControl.leading.constraint(equalTo: contentView.leading),
            panInputTextControl.trailing.constraint(equalTo: contentView.trailing),

            additionalCardDataInputView.top.constraint(equalTo: panInputTextControl.bottom),
            additionalCardDataInputView.leading.constraint(equalTo: contentView.leading),
            additionalCardDataInputView.trailing.constraint(equalTo: contentView.trailing),
            additionalCardDataInputView.bottom.constraint(equalTo: contentView.bottom),
        ]

        constraints += [
            scrollViewController.view.top.constraint(equalTo: view.top),
            scrollViewController.view.bottom.constraint(equalTo: view.bottomMargin),
            scrollViewController.view.leading.constraint(equalTo: view.leading),
            scrollViewController.view.trailing.constraint(equalTo: view.trailing),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - TextControl from Focus model

private extension BankCardFocus {
    func textControl(in controller: BankCardDataInputViewController) -> TextControl {
        switch self {
        case .pan:
            return controller.panInputTextControl
        case .expiryDate:
            return controller.additionalCardDataInputView.expiryDateControl
        case .csc:
            return controller.additionalCardDataInputView.cvcControl
        }
    }
}
