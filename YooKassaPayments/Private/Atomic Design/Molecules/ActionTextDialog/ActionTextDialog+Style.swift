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

// MARK: - Styles
extension ActionTextDialog {

    enum Styles {

        /// Style for `default` ActionTextDialog.
        static let `default` =
                UIView.Styles.transparent +
                        InternalStyle(name: "ActionTextDialog.default") { (view: ActionTextDialog) in
                            view.titleLabel.setStyles(UILabel.DynamicStyle.body,
                                                      UILabel.ColorStyle.secondary,
                                                      UILabel.Styles.multiline,
                                                      UILabel.Styles.alignCenter)
                            view.button.setStyles(UIButton.DynamicStyle.flat)
                        }

        /// Style for a ActionTextDialog to represent fail state.
        ///
        /// default style
        /// icon: fail with tintColor
        static let fail =
                ActionTextDialog.Styles.`default` +
                        InternalStyle(name: "ActionTextDialog.fail") { (view: ActionTextDialog) in
                            view.iconView.tintColor = nil
                            view.iconView.image = UIImage.PlaceholderView.fail
                        }

        /// Style for a ActionTextDialog to represent state for light theme
        ///
        /// icon color: for light theme (nobel)
        static let light =
                InternalStyle(name: "ActionTextDialog.light") { (view: ActionTextDialog) in
                    view.tintColor = .nobel
                }

        /// Style for a ActionTextDialog to represent state for dark theme
        ///
        /// icon color: for dark theme (doveGray)
        static let dark =
                InternalStyle(name: "ActionTextDialog.dark") { (view: ActionTextDialog) in
                    view.tintColor = .doveGray
                }

        /// Style for ActionTextDialog to represent agreement button
        static let agreement = InternalStyle(name: "agreement") { (view: ActionTextDialog) in
            view.button.appendStyle(UIButton.DynamicStyle.flat)
            view.button.appendStyle(UIButton.DynamicStyle.small)
            view.spaceBetweenTitleAndButton.constant = Space.triple
        }
    }
}
