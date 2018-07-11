/* The MIT License
 *
 * Copyright (c) 2007—2016 NBCO Yandex.Money LLC
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

struct Style {
    /// The name of the style
    let name: String

    /// Creates an instance of the style without registering in style storage.
    ///
    /// - parameter name: the name of the style
    fileprivate init(name: String) {
        self.name = name
    }

    /// Creates and registers a new style.
    ///
    /// - parameter name: the name of the style
    /// - parameter process: a method of processing style
    init<T: Stylable>(name: String, process: @escaping (T) -> Void) {
        assert(name.contains(" ") == false, "The style name must not contain space characters")
        self.init(name: name.replacingOccurrences(of: " ", with: "_"))
        StyleStorage.shared.register(name: name, process: process)
    }
}

/// Combine two style in one.
///
/// - parameter lhs: first style
/// - parameter rhs: second style
func + (lhs: Style, rhs: Style) -> Style {
    return Style(name: lhs.name + " " + rhs.name)
}
