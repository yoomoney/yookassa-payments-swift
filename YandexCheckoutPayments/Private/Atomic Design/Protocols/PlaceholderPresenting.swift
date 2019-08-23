/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2018 NBCO Yandex.Money LLC
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

/// Protocol to control the display of the placeholder.
/// - note: If you use VIPER architecture or similar you can use it for `view input` interface.
protocol PlaceholderPresenting {

    /// Show placeholder
    func showPlaceholder()

    /// Hide placeholder
    func hidePlaceholder()
}

/// Implementation of the protocol where the current type supports PlaceholderProvider, UIViewController
extension PlaceholderPresenting where Self: PlaceholderProvider & UIViewController {

    /// Show placeholder
    /// - note: Default implementation shows the placeholder on the main view of view controller
    func showPlaceholder() {
        showPlaceholder(on: view)
    }

    /// Hide placeholder
    /// - note: Default implementation removes placeholder from his parent view
    func hidePlaceholder() {
        placeholderView.removeFromSuperview()
    }

    /// Helper method for show placeholder on the specific view.
    /// The placeholder will be stretched by all sides of the view.
    ///
    /// - Parameter on: The specific view where placeholder will be placed
    func showPlaceholder(on view: UIView) {
        guard placeholderView.superview !== view else { return }
        if placeholderView.superview != nil {
            placeholderView.removeFromSuperview()
        }
        view.addSubview(placeholderView)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderView.top.constraint(equalTo: view.top),
            placeholderView.bottom.constraint(equalTo: view.bottom),
            placeholderView.leading.constraint(equalTo: view.leading),
            placeholderView.trailing.constraint(equalTo: view.trailing),
        ])
    }
}
