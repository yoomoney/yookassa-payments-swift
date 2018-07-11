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

import UIKit.UIImage

// MARK: - Internal styled images
extension UIImage {

    /// - Note: No need to make them  Use styles instead.

    static var clear: UIImage {
        return named("clearImage")
    }

    static var error: UIImage {
        return named("errorImage")
    }

    static var back: UIImage {
        return named("barButtonItem.back").withRenderingMode(.alwaysOriginal)
    }

    static var close: UIImage {
        return named("barButtonItem.close").withRenderingMode(.alwaysOriginal)
    }

    static var templatedClose: UIImage {
        return named("button.templatedClose").withRenderingMode(.alwaysTemplate)
    }

    enum NotificationView {
        static var success: UIImage {
            return named("notificationView.success")
        }
        static var info: UIImage {
            return named("notificationView.info")
        }
        static var error: UIImage {
            return named("notificationView.error")
        }
    }

    enum PlaceholderView {
        static var fail: UIImage {
            return named("placeholderView.fail").withRenderingMode(.alwaysTemplate)
        }
    }

    enum PaymentSystem {

        enum TextControl {
            static var bankCard: UIImage {
                return named("paymentSystem_unknownCard_textControl")
            }
            static var maestro: UIImage {
                return named("paymentSystem_maestro_textControl")
            }
            static var mir: UIImage {
                return named("paymentSystem_mir_textControl")
            }
            static var visa: UIImage {
                return named("paymentSystem_visa_textControl")
            }
            static var masterCard: UIImage {
                return named("paymentSystem_masterCard_textControl")
            }
            static var scan: UIImage {
                return named("BankCardDataInput.Scan")
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
        let underlineRect = UIEdgeInsetsInsetRect(rect, insets)
        context.setFillColor(config.line.color.cgColor)
        context.fill(underlineRect)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure("Can't get image from context")
            return UIImage()
        }
        return image
    }
}
