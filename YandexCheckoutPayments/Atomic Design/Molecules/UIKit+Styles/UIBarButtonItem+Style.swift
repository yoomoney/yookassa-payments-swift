/* The MIT License
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

import UIKit

// MARK: - Styles

extension UIBarButtonItem {

    enum Styles {

        // MARK: - Main styles

        /// Close bar button item.
        ///
        /// Image `barButtonItem.close`.
        static let close = Style(name: "close") { (item: UIBarButtonItem) in
            item.style = .plain
            item.image = .templatedClose
        }

        /// Back bar button item.
        ///
        /// Image `barButtonItem.back`.
        static let back = Style(name: "back") { (item: UIBarButtonItem) in
            item.style = .plain
            item.image = .back
        }

        /// Close bar button item with ability to set tint color.
        ///
        /// Image `button.templatedClose`.
        static let templatedClose = Style(name: "templatedClose") { (item: UIBarButtonItem) in
            item.tintColor = nil
            item.style = .plain
            item.image = .templatedClose
        }
    }

}
