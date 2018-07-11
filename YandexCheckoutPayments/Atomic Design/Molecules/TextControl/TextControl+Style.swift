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

extension TextControl {

    enum Styles {

        static let `default` = UIView.Styles.defaultBackground +
            Style(name: "default") { (item: TextControl) in
                item.textView.appendStyle(UIView.Styles.defaultBackground)
                item.clipsToBounds = true

                item.textView.isScrollEnabled = false
                item.textView.textContainerInset = .zero
                item.textView.textContainer.lineFragmentPadding = 0

                item.textView.font = .dynamicBody
                item.textView.textColor = .black

                item.topHintLabel.font = .dynamicCaption2
                item.topHintLabel.textColor = .nobel
                item.topHintLabel.numberOfLines = 0

                item.bottomHintLabel.font = .dynamicCaption2
                item.bottomHintLabel.numberOfLines = 0
                item.set(bottomHintColor: .nobel, for: .normal)
                item.set(bottomHintColor: .redOrange, for: .error)

                item.lineView.backgroundColor = .black5

                item.placeholderLabel.font = .dynamicBody
                item.placeholderLabel.textColor = .nobel
                item.placeholderLabel.numberOfLines = 0

                item.set(lineState: .filled(color: .mustard, height: 1), for: .normal)
                item.set(lineState: .filled(color: .redOrange, height: 1), for: .error)

                item.clearMode = .default
                item.placeholderMode = .default
                item.topHintMode = .default
                item.bottomHintMode = .default
                item.rightButtonMode = .default
                item.leftIconMode = .default
            }

        static let noAutocorrection = Style(name: "noAutocorrection") { (item: TextControl) in
            item.textView.autocorrectionType = .no
        }

        static let noSpellChecking = Style(name: "noSpellChecking") { (item: TextControl) in
            item.textView.spellCheckingType = .no
        }

        static let noAutoCapitalization = Style(name: "noAutoCapitalization") { (item: TextControl) in
            item.textView.autocapitalizationType = .none
        }

        static let password =
            TextControl.Styles.noSpellChecking +
            TextControl.Styles.noAutocorrection +
            TextControl.Styles.noAutoCapitalization

        static let paddingHorizontal10 = Style(name: "lineNormalState") { (item: TextControl) in
            item.padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        }

        static let bordered = Style(name: "bordered") { (item: TextControl) in
            item.layer.borderColor = UIColor.lightGray.cgColor
            item.layer.borderWidth = 1
        }

        static let rightButtonAsErrorImage = Style(name: "rightButtonAsErrorImage") { (item: TextControl) in
            item.rightButton.setImage(.error, for: .normal)
            item.rightButton.isUserInteractionEnabled = false
        }

        static let rightButtonWithoutImage = Style(name: "rightButtonWithoutImage") { (item: TextControl) in
            item.rightButton.setImage(nil, for: .normal)
            item.rightButton.isUserInteractionEnabled = true
        }

        static let leftIconVisible = Style(name: "leftIconVisible") { (item: TextControl) in
            item.leftIconMode = .always
        }

        static let leftIconHidden = Style(name: "leftIconHidden") { (item: TextControl) in
            item.leftIconMode = .never
        }

        static let cardDataInput = TextControl.Styles.default +
            TextControl.Styles.password +
            UIView.Styles.grayBackground +
            Style(name: "cardDataInput") { (item: TextControl) in
                item.textView.appendStyle(UIView.Styles.grayBackground)

                item.placeholderLabel.appendStyle(UILabel.DynamicStyle.headline1)
                item.topHintLabel.appendStyle(UILabel.DynamicStyle.caption2)

                item.textView.keyboardType = .numberPad

                item.textView.font = .dynamicHeadline1
            }

        static let linkedCardDataInput = cardDataInput +
            Style(name: "linkedCardDataInput") { (item: TextControl) in
                item.textView.textColor = .doveGray
            }

        static let cardDataInputWithScan = Style(name: "cardDataInputWithScan") { (item: TextControl) in
            item.rightButton.setImage(UIImage.PaymentSystem.TextControl.scan, for: .normal)
            item.rightButtonMode = .whileEmpty
        }

        static let cardDataInputWithoutScan = Style(name: "cardDataInputWithoutScan") { (item: TextControl) in
            item.rightButton.setImage(nil, for: .normal)
            item.rightButtonMode = .default
        }

        // MARK: - The visibility of hints styles

        /// Style for text control without top hint.
        static let withoutTopHint = Style(name: "withoutTopHint") { (item: TextControl) in
            item.topHintMode = .never
        }

        /// Style for text control without bottom hint.
        static let withoutBottomHint = Style(name: "withoutBottomHint") { (item: TextControl) in
            item.bottomHintMode = .never
        }

        /// Style for text control without hints.
        static let withoutHints = withoutTopHint + withoutBottomHint

        // MARK: - The line styles

        static let tintLine = Style(name: "TextControl.Styles.tintLine") { (item: TextControl) in
            item.set(lineState: .filled(color: item.tintColor, height: 1), for: .normal)
        }
    }
}
