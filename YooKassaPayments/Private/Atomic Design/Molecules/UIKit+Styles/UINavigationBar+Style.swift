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

import UIKit

// MARK: - Styles
extension UINavigationBar {

    enum Styles {

        // MARK: - Main styles

        static let `default` = InternalStyle(name: "default") { (view: UINavigationBar) in

            let barTintColor: UIColor
            if #available(iOS 11, *) {
                view.prefersLargeTitles = false
            }
            if #available(iOS 13, *) {
                barTintColor = .systemBackground
            } else {
                barTintColor = .cararra
            }

            view.isTranslucent = false
            view.barTintColor = barTintColor
            view.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.AdaptiveColors.primary,
            ]
            view.shadowImage = UIImage()
            view.clipsToBounds = true
            view.layoutMargins = UIEdgeInsets(top: 0, left: Space.double, bottom: 0, right: Space.double)
            view.preservesSuperviewLayoutMargins = true
        }
    }
}
