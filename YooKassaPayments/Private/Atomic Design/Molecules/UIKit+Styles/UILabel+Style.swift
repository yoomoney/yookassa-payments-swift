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

import Foundation
import UIKit

extension UILabel {

    // MARK: - Styles

    enum Styles {

        // MARK: - Main styles

        /// Display style.
        ///
        /// display font, black color
        static let display = makeStyle(name: "display", attributes: [
            .font: UIFont.display,
            .foregroundColor: UIColor.black,
        ])

        /// Headline style.
        ///
        /// headline font, black color
        static let headline = makeStyle(name: "headline", attributes: [
            .font: UIFont.headline,
            .foregroundColor: UIColor.black,
        ])

        /// Title style.
        ///
        /// title font, black color
        static let title = makeStyle(name: "title", attributes: [
            .font: UIFont.title,
            .foregroundColor: UIColor.black,
        ])

        /// Subhead1 style.
        ///
        /// subhead1 font, black color, uppercased
        static let subhead1 = uppercased + makeStyle(name: "subhead1", attributes: [
            .font: UIFont.subhead1,
            .foregroundColor: UIColor.black,
            .kern: UIFont.Kern.m,
        ])

        /// Subhead2 style.
        ///
        /// subhead2 font, black50 color, uppercased
        static let subhead2 = makeStyle(name: "subhead2", attributes: [
            .font: UIFont.subhead2,
            .foregroundColor: UIColor.black50,
            .kern: UIFont.Kern.l,
        ]) + uppercased

        /// Body1 style.
        ///
        /// body1 font, black color
        static let body1 = makeStyle(name: "body1", attributes: [
            .font: UIFont.body1,
            .foregroundColor: UIColor.black,
        ])

        /// Body2 style.
        ///
        /// body2 font, black color
        static let body2 = makeStyle(name: "body2", attributes: [
            .font: UIFont.body2,
            .foregroundColor: UIColor.black,
        ])

        /// Caption style.
        ///
        /// caption font, black50 color
        static let caption = makeStyle(name: "caption", attributes: [
            .font: UIFont.caption,
            .foregroundColor: UIColor.black50,
        ])

        /// Button style.
        ///
        /// button font, black color, uppercased
        static let button = makeStyle(name: "button", attributes: [
            .font: UIFont.button,
            .foregroundColor: UIColor.black,
            .kern: UIFont.Kern.m,
        ]) + uppercased

        /// Secondary button style.
        ///
        /// secondary button font, blueRibbon color, uppercased
        static let secondaryButton = makeStyle(name: "secondaryButton", attributes: [
            .font: UIFont.secondaryButton,
            .foregroundColor: UIColor.blueRibbon,
            .kern: UIFont.Kern.m,
        ]) + uppercased

        // MARK: - Modifications

        /// Uppercasing all characters
        static let uppercased = InternalStyle(name: "uppercased") { (label: UILabel) in
            guard let text = label.text,
                  let attributedText = label.attributedText.flatMap(NSMutableAttributedString.init)  else { return }
            let range = NSRange(location: 0, length: (text as NSString).length)
            attributedText.replaceCharacters(in: range, with: text.uppercased())
            label.attributedText = attributedText
        }

        /// Appling Ultralight face for fractional part of string representing decimal value
        static let ultralightFractionalPart
            = InternalStyle(name: "UILabel.ultralightFractionalPart") { (label: UILabel) in
                guard let text = label.text,
                      let attributedText = label.attributedText.flatMap(NSMutableAttributedString.init) else { return }

                let decimalSeparator = Character(NSLocale.current.decimalSeparator ?? ".")
                let decimalParts = text.split(separator: decimalSeparator)
                guard decimalParts.count == 2, decimalParts[1].isEmpty == false else { return }

                let range = NSRange(location: decimalParts[0].count + 1, length: decimalParts[1].count)
                let descriptor = label.font.fontDescriptor
                    .withFamily(label.font.familyName)
                    .withFace("Ultralight")
                let font = UIFont(descriptor: descriptor, size: 0)
                attributedText.setAttributes([.font: font], range: range)
                label.attributedText = attributedText
            }

        // MARK: - Color

        /// Primary modification
        ///
        /// black color
        static let primary = makeStyle(name: "primary", attributes: [
            .foregroundColor: UIColor.black,
        ])

        /// Secondary modification
        ///
        /// black60 color
        static let secondary = makeStyle(name: "secondary", attributes: [
            .foregroundColor: UIColor.black60,
        ])

        /// Disabled modification
        ///
        /// black30 color
        static let disabled = makeStyle(name: "disabled", attributes: [
            .foregroundColor: UIColor.black30,
        ])

        // MARK: - Lines number styles

        /// Style for multiline label.
        static let multiline = InternalStyle(name: "multiline") { (label: UILabel) in
            label.numberOfLines = 0
        }

        /// Style for single-line label.
        static let singleLine = InternalStyle(name: "singleLine") { (label: UILabel) in
            label.numberOfLines = 1
        }

        /// Style for double-line label.
        static let doubleLine = InternalStyle(name: "doubleLine") { (label: UILabel) in
            label.numberOfLines = 2
        }

        // MARK: - Align styles

        /// Style for align text left.
        static let alignLeft = makeStyle(name: "alignLeft") {
            let paragraph = $0
            paragraph.alignment = .left
            return paragraph
        }

        /// Style for align text right.
        static let alignRight = makeStyle(name: "alignRight") {
            let paragraph = $0
            paragraph.alignment = .right
            return paragraph
        }

        /// Stile for align text center.
        static let alignCenter = makeStyle(name: "alignCenter") {
            let paragraph = $0
            paragraph.alignment = .center
            return paragraph
        }

        // MARK: - Line break styles

        /// Stile for truncating head.
        static let truncatingHead = makeStyle(name: "truncatingHead") {
            let paragraph = $0
            paragraph.lineBreakMode = .byTruncatingHead
            return paragraph
        }

        // MARK: - ActionSheet

        /// Style for simple action sheet title label.
        static let simpleActionSheetItem = Styles.body1 + Styles.multiline

        /// Style for simple action sheet title label.
        static let actionSheetHeader = Styles.button + Styles.multiline

        // MARK: - Internal Styles

        /// Style for error toast.
        ///
        /// multiline, body2 font
        static let toast =
                multiline +
                makeStyle(name: "toast", attributes: [
                    .font: UIFont.body2,
                    .foregroundColor: UIColor.white90,
                ])
                + UIView.Styles.heightAsContent
    }
}

extension UILabel {

    // MARK: - Dynamic Fonts

    enum DynamicStyle {

        static let title1 = InternalStyle(name: "dynamic.title1") { (label: UILabel) in
            if #available(iOS 11.0, *) {
                label.font = .dynamicTitle1
            } else {
                label.font = .title1
            }
        }

        static let title2 = InternalStyle(name: "dynamic.title2") { (label: UILabel) in
            if #available(iOS 9.0, *) {
                label.font = .dynamicTitle2
            } else {
                label.font = .title2
            }
        }

        @available (iOS 9.0, *)
        static let title3 = InternalStyle(name: "dynamic.title3") { (label: UILabel) in
            label.font = .dynamicTitle3
        }

        static let headline1 = InternalStyle(name: "dynamic.headline1") { (label: UILabel) in
            label.font = .dynamicHeadline1
        }

        static let body = InternalStyle(name: "dynamic.body") { (label: UILabel) in
            label.font = .dynamicBody
        }

        static let bodySemibold = InternalStyle(name: "dynamic.bodySemibold") { (label: UILabel) in
            label.font = .dynamicBodySemibold
        }

        static let bodyMedium = InternalStyle(name: "dynamic.bodyMedium") { (label: UILabel) in
            label.font = .dynamicBodyMedium
        }

        static let headline2 = InternalStyle(name: "dynamic.headline2") { (label: UILabel) in
            label.font = .dynamicHeadline2
        }

        static let headline3 = InternalStyle(name: "dynamic.headline3") { (label: UILabel) in
            label.font = .dynamicHeadline3
        }

        static let caption1 = InternalStyle(name: "dynamic.caption1") { (label: UILabel) in
            label.font = .dynamicCaption1
        }

        static let caption2 = InternalStyle(name: "dynamic.caption2") { (label: UILabel) in
            label.font = .dynamicCaption2
        }

        static let display1 = InternalStyle(name: "dynamic.display1") { (label: UILabel) in
            label.font = .display1
        }
    }

    // MARK: - Colors

    enum ColorStyle {
        private static let black = InternalStyle(name: "color.black") { (label: UILabel) in
            if #available(iOS 13.0, *) {
                label.textColor = .label
            } else {
                label.textColor = .black
            }
        }

        private static let doveGray = InternalStyle(name: "color.doveGray") { (label: UILabel) in
            if #available(iOS 13.0, *) {
                label.textColor = .secondaryLabel
            } else {
                label.textColor = .doveGray
            }
        }

        private static let nobel = InternalStyle(name: "color.nobel") { (label: UILabel) in
            if #available(iOS 13.0, *) {
                label.textColor = .tertiaryLabel
            } else {
                label.textColor = .nobel
            }
        }

        static let primary = black

        static let secondary = doveGray

        static let ghost = nobel

        static let inverse = InternalStyle(name: "label.colorStyle.inverse") { (label: UILabel) in
            label.textColor = .inverse
        }

        static let inverseTranslucent = InternalStyle(name: "label.colorStyle.inverseTranslucent") { (label: UILabel) in
            label.textColor = .inverseTranslucent
        }

        enum Link {
            static let normal = InternalStyle(name: "color.link.normal") { (label: UILabel) in
                label.textColor = .link
            }

            static let highlighted = InternalStyle(name: "color.link.highlighted") { (label: UILabel) in
                label.textColor = UIColor.link.withAlphaComponent(0.5)
            }

            static let disabled = UILabel.ColorStyle.ghost
        }
    }
}

private func makeStyle(name: String, attributes: [NSAttributedString.Key: Any]) -> InternalStyle {
    return InternalStyle(name: name) { (label: UILabel) in
        label.attributedText = label.attributedText.flatMap {
            makeAttributedString(attributedString: $0, attributes: attributes)
        }
    }
}

private func makeStyle(name: String,
                       paragraphModifier: @escaping (NSMutableParagraphStyle) -> NSParagraphStyle) -> InternalStyle {
    return InternalStyle(name: name) { (label: UILabel) in
        guard let attributedText = label.attributedText.flatMap(NSMutableAttributedString.init),
              attributedText.length > 0 else { return }
        let range = NSRange(location: 0, length: (attributedText.string as NSString).length)
        var paragraph = (attributedText.attribute(.paragraphStyle,
                                                  at: 0,
                                                  effectiveRange: nil) as? NSParagraphStyle) ?? .default
        // swiftlint:disable:next force_cast
        paragraph = paragraphModifier(paragraph.mutableCopy() as! NSMutableParagraphStyle)
        attributedText.addAttributes([.paragraphStyle: paragraph], range: range)
        label.attributedText = attributedText
    }
}

private func makeAttributedString(attributedString: NSAttributedString,
                                  attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {

    let range = NSRange(location: 0, length: (attributedString.string as NSString).length)
    let attributedString = NSMutableAttributedString(attributedString: attributedString)
    attributedString.addAttributes(attributes, range: range)
    return attributedString
}
