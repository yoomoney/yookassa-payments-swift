/* The MIT License
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

import Foundation.NSRange
import class UIKit.UITextPosition
import class UIKit.UITextRange

// MARK: - InputView
extension TextControl: InputView {

    var inputText: String? {
        get {
            return text
        }
        set {
            text = newValue
        }
    }

    var beginningOfDocument: UITextPosition {
        return textView.beginningOfDocument
    }

    var selectedTextRange: UITextRange? {
        get {
            return textView.selectedTextRange
        }
        set {
            textView.selectedTextRange = newValue
        }
    }

    func offset(from: UITextPosition, to toPosition: UITextPosition) -> Int {
        return textView.offset(from: from, to: toPosition)
    }

    func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
        return textView.position(from: position, offset: offset)
    }

    func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
        return textView.textRange(from: fromPosition, to: toPosition)
    }
}
