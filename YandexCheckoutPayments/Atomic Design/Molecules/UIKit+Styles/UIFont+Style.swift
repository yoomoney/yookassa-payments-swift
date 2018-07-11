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

extension UIFont {

    @available (iOS 11.0, *)
    static var dynamicTitle1: UIFont {
        return UIFont.makeFont(style: .largeTitle, face: "Bold")
    }

    @available (iOS 9.0, *)
    static var dynamicTitle2: UIFont {
        return UIFont.makeFont(style: .title2, face: "Bold")
    }

    @available (iOS 9.0, *)
    static var dynamicTitle2Light: UIFont {
        return UIFont.makeFont(style: .title2, face: "Light")
    }

    @available (iOS 9.0, *)
    static var dynamicTitle3: UIFont {
        return UIFont.makeFont(style: .title3, face: "Semibold")
    }

    static var title1: UIFont {
        return UIFont.makeFont(size: 28, face: "Regular")
    }

    static var title2: UIFont {
        return UIFont.makeFont(size: 22, face: "Regular")
    }

    static var dynamicHeadline1: UIFont {
        return UIFont.makeFont(style: .headline, face: "Semibold")
    }

    static var dynamicHeadline2: UIFont {
        return UIFont.makeFont(style: .footnote, face: "Bold")
    }

    static var dynamicHeadline3: UIFont {
        return UIFont.makeFont(style: .caption1, face: "Regular")
    }

    static var dynamicBody: UIFont {
        if #available(iOS 9.0, *) {
            return UIFont.makeFont(style: .callout, face: "Regular")
        } else {
            return UIFont.makeFont(style: .body, face: "Regular")
        }
    }

    static var dynamicBodySemibold: UIFont {
        if #available(iOS 9.0, *) {
            return UIFont.makeFont(style: .callout, face: "Semibold")
        } else {
            return UIFont.makeFont(style: .body, face: "Semibold")
        }
    }

    static var dynamicBodyMedium: UIFont {
        if #available(iOS 9.0, *) {
            return UIFont.makeFont(style: .callout, face: "Medium")
        } else {
            return UIFont.makeFont(style: .body, face: "Medium")
        }
    }

    static var dynamicCaption1: UIFont {
        return UIFont.makeFont(style: .footnote, face: "Regular")
    }

    static var dynamicCaption2: UIFont {
        return UIFont.makeFont(style: .caption2, face: "Regular")
    }

    static var caption1: UIFont {
        return UIFont.makeFont(size: 13, face: "Regular")
    }

    static var display1: UIFont {
        return UIFont.makeFont(size: 64, face: "Bold")
    }

    private static func makeFont(style: UIFontTextStyle, face: String) -> UIFont {
        var descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let size = descriptor.fontAttributes[UIFontDescriptor.AttributeName.size] as? Float ?? 0
        descriptor = UIFontDescriptor()
        let font = UIFont.systemFont(ofSize: CGFloat(size))
        descriptor = descriptor.withFamily(font.familyName)
        descriptor = descriptor.withSize(CGFloat(size))
        descriptor = descriptor.withFace(face)
        return UIFont(descriptor: descriptor, size: 0)
    }

    private static func makeFont(size: CGFloat, face: String) -> UIFont {
        var descriptor = UIFontDescriptor()
        let font = UIFont.systemFont(ofSize: size)
        descriptor = descriptor.withFamily(font.familyName)
        descriptor = descriptor.withSize(CGFloat(size))
        descriptor = descriptor.withFace(face)
        return UIFont(descriptor: descriptor, size: 0)
    }
}

extension UIFont {
    static let display = lightSystemFont(ofSize: 32)
    static let headline = lightSystemFont(ofSize: 25)
    static let title = lightSystemFont(ofSize: 19)
    static let subhead1 = semiboldSystemFont(ofSize: 13)
    static let subhead2 = systemFont(ofSize: 12)
    static let body1 = lightSystemFont(ofSize: 16)
    static let body2 = lightSystemFont(ofSize: 14)
    static let caption = lightSystemFont(ofSize: 12)
    static let button = systemFont(ofSize: 14)
    static let secondaryButton = mediumSystemFont(ofSize: 12)
    static let legal = systemFont(ofSize: 11)
}

// MARK: - Kern sizes
extension UIFont {
    enum Kern {
        static let s = 0.4
        static let m = 0.8
        static let l = 1.2
    }
}

extension UIFont {

    static func lightSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let lightFontDescriptor = fontDescriptor.withFace("Light")
        return UIFont(descriptor: lightFontDescriptor, size: fontSize)
    }

    static func semiboldSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let lightFontDescriptor = fontDescriptor.withFace("Semibold")
        return UIFont(descriptor: lightFontDescriptor, size: fontSize)
    }

    static func mediumSystemFont(ofSize fontSize: CGFloat) -> UIFont {
        let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let lightFontDescriptor = fontDescriptor.withFace("Medium")
        return UIFont(descriptor: lightFontDescriptor, size: fontSize)
    }
}
