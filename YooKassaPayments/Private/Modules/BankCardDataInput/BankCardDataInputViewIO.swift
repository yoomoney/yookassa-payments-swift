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

import class UIKit.UIImage

enum BankCardFocus {
    case pan
    case expiryDate
    case csc
}

/// Protocol for configure view
protocol BankCardDataInputViewInput: ActivityIndicatorPresenting, PlaceholderPresenting {

    func setNavigationBarTitle(_ title: String)

    func setPanInputTextControlHint(_ hint: String)
    func setPanInputTextControlValue(_ value: String)
    func setPanInputTextControlIsEnabled(_ isEnabled: Bool)
    func setPanInputTextControlDisabledStyle()
    func setPanIsValid(_ isValid: Bool)
    func setPanInputScanModeIsEnabled(_ isEnabled: Bool)

    func setExpiryDateTextControlHint(_ hint: String)
    func setExpiryDateTextControlValue(_ value: String)
    func setExpiryDateTextControlFormattedValue(_ value: String)
    func setExpiryDateTextControlIsEnabled(_ isEnabled: Bool)
    func setExpiryDateTextControlDisabledStyle()
    func setExpiryDateIsValid(_ isValid: Bool)

    func setCvcTextControlHint(_ hint: String)

    func setConfirmButtonTitle(_ title: String)
    func setConfirmButtonEnabled(_ isEnabled: Bool)

    func endEditing(_ force: Bool)

    func showPlaceholder(message: String)

    func setBankLogoImage(_ image: UIImage)

    var focus: BankCardFocus? { get set }
}

/// Protocol to informing view state
protocol BankCardDataInputViewOutput: ActionTextDialogDelegate {
    func setupView()
    func viewDidAppear()
    func viewDidDisappear()
    func didSetPan(_ pan: String)
    func didSetExpiryDate(_ expiryDate: String)
    func didSetCsc(_ csc: String)
    func confirmButtonDidPress()
    func closeBarButtonItemDidPress()
    func didPressScanButton()
}
