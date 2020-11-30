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

import UIKit.UIImage

// MARK: - Internal styled images
extension UIImage {

    /// - Note: No need to make them  Use styles instead.

    static var clear: UIImage {
        return #imageLiteral(resourceName: "clearImage")
    }

    static var error: UIImage {
        return #imageLiteral(resourceName: "errorImage")
    }

    static var back: UIImage {
        return #imageLiteral(resourceName: "barButtonItem.back").withRenderingMode(.alwaysOriginal)
    }

    static var close: UIImage {
        return #imageLiteral(resourceName: "barButtonItem.close").withRenderingMode(.alwaysOriginal)
    }

    static var templatedClose: UIImage {
        return #imageLiteral(resourceName: "button.templatedClose").withRenderingMode(.alwaysTemplate)
    }

    enum PlaceholderView {
        static var fail: UIImage {
            return #imageLiteral(resourceName: "placeholderView.fail").withRenderingMode(.alwaysTemplate)
        }

        static var success: UIImage {
            return #imageLiteral(resourceName: "emptyState.success")
        }
    }

    enum PaymentSystem {
        enum TextControl {
            static var scan: UIImage {
                return #imageLiteral(resourceName: "BankCardDataInput.Scan")
            }
        }
    }
}

// MARK: - UIImage: Images factory
private extension UIImage {

    struct UnderlinedImageConfig {
        let size: CGSize
        let backgroundColor: UIColor
        let line: (width: CGFloat, color: UIColor)
    }

    static func makeUnderlinedImage(config: UnderlinedImageConfig) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(config.size, true, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure("Can't get graphic context")
            return UIImage()
        }

        let rect = CGRect(origin: .zero, size: config.size)
        context.setFillColor(config.backgroundColor.cgColor)
        context.fill(rect)

        let insets = UIEdgeInsets(top: rect.size.height - config.line.width, left: 0, bottom: 0, right: 0)
        let underlineRect = rect.inset(by: insets)
        context.setFillColor(config.line.color.cgColor)
        context.fill(underlineRect)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure("Can't get image from context")
            return UIImage()
        }
        return image
    }
}
