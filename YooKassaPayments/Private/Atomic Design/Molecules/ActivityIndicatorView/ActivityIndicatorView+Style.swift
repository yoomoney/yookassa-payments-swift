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

extension ActivityIndicatorView {

    enum Styles {

        /// Light style
        ///
        /// transparent background color, default activity indicator
        static let light = InternalStyle(name: "ActivityIndicatorView.Styles.light") { (view: ActivityIndicatorView) in
            view.setStyles(UIView.Styles.transparent)
            view.activity.setStyles(ActivityIndicator.Styles.default)
        }

        /// Dark style
        ///
        /// semiTransparent background color, default activity indicator
        static let dark = InternalStyle(name: "ActivityIndicatorView.Styles.dark") { (view: ActivityIndicatorView) in
            view.setStyles(UIView.Styles.semiTransparent)
            view.activity.setStyles(ActivityIndicator.Styles.default)
        }

        /// Heavy light style
        ///
        /// gray background color, default activity indicator
        static let heavyLight = InternalStyle(
            name: "ActivityIndicatorView.Styles.heavyLight") { (view: ActivityIndicatorView) in

            view.setStyles(UIView.Styles.grayBackground)
            view.activity.setStyles(ActivityIndicator.Styles.default)
        }

        /// Cloudy style
        ///
        /// cararra 50% alpha background color, default activity indicator
        static let cloudy = InternalStyle(name: "ActivityIndicatorView.cloudy") { (view: ActivityIndicatorView) in
            view.backgroundColor = UIColor.cararra.withAlphaComponent(0.5)
            view.activity.setStyles(ActivityIndicator.Styles.default)
        }
    }
}
