/* The MIT License
 *
 * Copyright © 2022 NBCO YooMoney LLC
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

/// Not selectable text view, can be used for text views with links
class LinkedTextView: UITextView {

    override var canBecomeFirstResponder: Bool {
        return false
    }

    /// Function disable selection for text and allow click on links.
    /// - See also: https://stackoverflow.com/questions/36198299/uitextview-disable-selection-allow-links
    ///
    /// - Parameter gestureRecognizer: An object whose class descends from the UIGestureRecognizer class.
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
            defer {
                super.addGestureRecognizer(gestureRecognizer)
            }

            guard let targets = gestureRecognizer.value(forKey: "_targets") as? NSMutableArray else {
                return
            }

            let targetAndAction = targets.firstObject
            let actions = [
                "action=loupeGesture:",
                "action=longDelayRecognizer:",
                "action=oneFingerForcePan:",
                "action=_handleRevealGesture:",
            ]

            for action in actions {
                if targetAndAction.debugDescription.contains(action) {
                    gestureRecognizer.isEnabled = false
                }
            }
        }
    }
}
