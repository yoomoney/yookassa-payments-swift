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

import CoreGraphics
import UIKit

// MARK: - Extension for generating and changing image
extension UIImage {

    /// Generate image of color of {1, 1} size.
    ///
    /// - parameter color: color of new image
    ///
    /// - returns: generated image
    static func image(color: UIColor) -> UIImage {

        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure("Can't get graphic context")
            return UIImage()
        }

        context.setFillColor(color.cgColor)
        context.fill(rect)

        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure("Can't get image from context")
            return UIImage()
        }

        return image
    }

    /// Scale image to size.
    ///
    /// - parameter size: size for scaling
    ///
    /// - returns: new scaled image
    func scaled(to size: CGSize) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure("Can't get graphic context")
            return self
        }
        let rect = CGRect(origin: .zero, size: size)
        context.clear(rect)
        draw(in: rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure("Can't get image from context")
            return self
        }
        return image
    }

    /// Round image with corner radius.
    ///
    /// - parameter cornerRadius: corner radius for rounding
    ///
    /// - returns: new rounded image image
    func rounded(cornerRadius: CGFloat) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure("Can't get graphic context")
            return self
        }

        let rect = CGRect(origin: .zero, size: size)
        context.addPath(UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath)
        context.clip()

        draw(in: rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure("Can't get image from context")
            return self
        }

        return image
    }
}

// MARK: - Internal image tools
extension UIImage {

    /// Generate image with tint color
    ///
    /// - parameter color: color of new image
    ///
    /// - returns: generated image
    func colorizedImage(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure("Can't get graphic context")
            return self
        }
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.normal)
        let rect = CGRect(origin: .zero, size: size)
        guard let cgImage = self.cgImage else {
            assertionFailure("Can't get cgimage")
            return self
        }
        context.clip(to: rect, mask: cgImage)
        color.setFill()
        context.fill(rect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure("Can't get image from context")
            return self
        }
        return newImage
    }
}
