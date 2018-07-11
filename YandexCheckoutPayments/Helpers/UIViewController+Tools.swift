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

import UIKit

extension UIViewController {

    /// If the current controller is inside the navigation controller and is the only one on the navigation stack,
    /// then display a styled close button in the left part of the navigation bar.
    ///
    /// - Parameters:
    ///   - target: The target object, the object whose action method is called. `self` by default.
    ///   - action: A selector identifying the action method to be called.
    func addCloseButtonIfNeeded(target: AnyObject = self as AnyObject, action: Selector) {
        guard navigationController?.viewControllers.first === self else { return }

        let item = UIBarButtonItem()
        item.setStyles(UIBarButtonItem.Styles.close)
        item.target = target
        item.action = action
        navigationItem.leftBarButtonItem = item
    }
}
