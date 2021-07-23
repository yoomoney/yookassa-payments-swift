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

protocol Stylable: NSObjectProtocol {

    /// Set and apply styles to element.
    ///
    /// - note: Use this method for applying styles.
    ///
    /// - parameter styles: styles to apply
    func setStyles(_ styles: InternalStyle...)

    /// Remove styles from element.
    ///
    /// - note: This does not remove style changes. But previous styles reapply.
    ///
    /// - parameter style: style for remove
    func removeStyle(_ style: InternalStyle)

    /// Append style to element. If style already exist do nothing.
    ///
    /// - parameter style: style for append
    func appendStyle(_ style: InternalStyle)

    /// Apply the set styles.
    func applyStyles()
}

extension Stylable {

    func setStyles(_ styles: InternalStyle...) {
        self.styles = styles.map { $0.name }.joined(separator: " ")
    }

    func removeStyle(_ style: InternalStyle) {
        styles = styles?.components(separatedBy: " ")
            .filter { $0 != style.name }
            .joined(separator: " ")
    }

    func appendStyle(_ style: InternalStyle) {
        guard styles?.components(separatedBy: " ").contains(style.name) != true else { return }
        styles = [styles, style.name].compactMap { $0 }.joined(separator: " ")
    }

    func applyStyles() {
        styles?.components(separatedBy: " ")
            .compactMap { StyleStorage.shared.styles[$0] } // remove nil
            .flatMap { $0 } // Unpack [[]]
            .forEach { $0(self) }
    }
}

private enum AssociatedKeys {
    /// Key for associated property
    static var style = "YooKassa_StyleAssociatedKey"
}

private extension Stylable {

    /// View's styles separated by space symbol.
    ///
    /// Changing this property call apply styles method.
    var styles: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.style) as? String
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.style,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            if newValue != nil {
                applyStyles()
            }
        }
    }
}

extension UIView: Stylable {}

extension UINavigationItem: Stylable {}

extension UIBarItem: Stylable {}
