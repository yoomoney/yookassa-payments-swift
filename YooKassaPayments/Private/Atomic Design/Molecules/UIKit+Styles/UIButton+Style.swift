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

// MARK: - Styles
extension UIButton {

    enum Styles {

        // MARK: - Main styles

        /// Style for primary button.
        static let primary = InternalStyle(name: "primary") { (button: UIButton) in
            let tintColor: UIColor = button.tintColor

            button.setBackgroundImage(roundedBackground(color: tintColor), for: .normal)
            button.setBackgroundImage(roundedBackground(color: .highlighted(from: tintColor)), for: .highlighted)
            button.setBackgroundImage(roundedBackground(color: .mousegrey), for: .disabled)

            let colorsByStates: [(state: UIControl.State, foreground: UIColor)] = [
                (.normal, .inverse),
                (.highlighted, .inverse),
                (.disabled, .nobel),
            ]

            colorsByStates.forEach { (state, color) in
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.button,
                    .kern: UIFont.Kern.m,
                    .foregroundColor: color,
                    ]
                let attributedString = button.title(for: state).map {
                    NSAttributedString(string: $0.uppercased(), attributes: attributes)
                }
                button.setAttributedTitle(attributedString, for: state)
            }

            button.height.constraint(equalToConstant: 56).isActive = true
        }

        /// Style for primary rounded button.
        static let addition = InternalStyle(name: "addition") { (button: UIButton) in
            let tintColor: UIColor = button.tintColor

            button.setBackgroundImage(roundedBackground(color: tintColor, cornerRadius: cornerRadius), for: .normal)
            button.setBackgroundImage(roundedBackground(color: .highlighted(from: tintColor),
                                                        cornerRadius: cornerRadius),
                                      for: .highlighted)
            button.setBackgroundImage(roundedBackground(color: .mousegrey, cornerRadius: cornerRadius), for: .disabled)

            let attributes: [(state: UIControl.State, font: UIFont, kern: Double, foreground: UIColor)] = [
                (.normal, UIFont.button, UIFont.Kern.m, .inverse),
                (.highlighted, UIFont.button, UIFont.Kern.m, .inverse),
                (.disabled, UIFont.button, UIFont.Kern.m, .nobel),
            ]

            attributes.forEach { attribute in
                let attributedString = button.title(for: attribute.state).map {
                    NSAttributedString(string: $0.uppercased(),
                                       attributes: [
                                        .font: attribute.font,
                                        .kern: attribute.kern,
                                        .foregroundColor: attribute.foreground,
                        ])
                }
                button.setAttributedTitle(attributedString, for: attribute.state)
            }

            button.height.constraint(equalToConstant: 48).isActive = true
        }

        /// Style for flat button.
        static let flat = InternalStyle(name: "flat") { (button: UIButton) in
            let tintColor: UIColor = button.tintColor
            var stateColors: [(UIControl.State, UIColor)] = [
                (.normal, tintColor),
                (.highlighted, .highlighted(from: tintColor)),
                (.disabled, .nobel),
            ]
            stateColors.forEach { (state, color) in
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.subhead2,
                    .kern: UIFont.Kern.m,
                    .foregroundColor: color,
                ]
                let attributedString = button.title(for: state).map {
                    NSAttributedString(string: $0.uppercased(), attributes: attributes)
                }
                button.setAttributedTitle(attributedString, for: state)
            }
            button.height.constraint(equalToConstant: 48).isActive = true
        }

        /// Style for buttons like system button.
        static let link = InternalStyle(name: "link") { (button: UIButton) in
            let tintColor: UIColor = button.tintColor
            button.setTitleColor(tintColor, for: .normal)
            button.setTitleColor(.highlighted(from: tintColor), for: .highlighted)
            button.setTitleColor(.nobel, for: .disabled)
            button.titleLabel?.font = UIFont.subhead2
            button.contentHorizontalAlignment = .left
        }

        /// Close button with ability to set tint color.
        ///
        /// Image `button.templatedClose`.
        static let templatedClose = InternalStyle(name: "templatedClose") { (button: UIButton) in
            button.setImage(.templatedClose, for: .normal)
        }

        // MARK: - Control specific styles

        /// Clear button style
        static let clear = InternalStyle(name: "clear") { (button: UIButton) in
            button.setImage(.clear, for: .normal)
        }

        // MARK: - Fileprivate

        /// Generate rounded image for button background.
        fileprivate static func roundedBackground(color: UIColor, cornerRadius: CGFloat = 0) -> UIImage {
            let side = cornerRadius * 2 + 2
            let size = CGSize(width: side, height: side)
            return UIImage.image(color: color)
                .scaled(to: size)
                .rounded(cornerRadius: cornerRadius)
                .resizableImage(withCapInsets: UIEdgeInsets(top: cornerRadius,
                                                            left: cornerRadius,
                                                            bottom: cornerRadius,
                                                            right: cornerRadius))
        }

        // MARK: - Background images

        fileprivate static let cornerRadius: CGFloat = 6

        fileprivate static let lightGoldBackgroundRounded6 = roundedBackground(color: .lightGold,
                                                                               cornerRadius: cornerRadius)
        fileprivate static let galleryBackgroundRounded6 = roundedBackground(color: .gallery,
                                                                             cornerRadius: cornerRadius)
        fileprivate static let dandelionBackgroundRounded6 = roundedBackground(color: .dandelion,
                                                                               cornerRadius: cornerRadius)
        fileprivate static let dandelion80BackgroundRounded6 = roundedBackground(color: .dandelion80,
                                                                                 cornerRadius: cornerRadius)
        fileprivate static let mercuryBackgroundRounded6 = roundedBackground(color: .mercury,
                                                                             cornerRadius: cornerRadius)
        fileprivate static let mustardBackgroundRounded6 = roundedBackground(color: .mustard,
                                                                             cornerRadius: cornerRadius)
        fileprivate static let creamBruleeBackgroundRounded6 = roundedBackground(color: .creamBrulee,
                                                                             cornerRadius: cornerRadius)
        fileprivate static let dandelionBackground = roundedBackground(color: .dandelion)
        fileprivate static let dandelion80Background = roundedBackground(color: .dandelion80)
        fileprivate static let galleryBackground = roundedBackground(color: .gallery)
        fileprivate static let mercuryBackground = roundedBackground(color: .mercury)
    }
}

extension UIButton {

    private func setColorizedImage(_ image: UIImage,
                                   color: UIColor,
                                   for state: UIControl.State) {
        let colorizedImage = image.colorizedImage(color: color)
        self.setImage(colorizedImage, for: state)
    }

    enum DynamicStyle {

        /// Style for primary button.
        static let primary = InternalStyle(name: "button.dynamic.primary") { (button: UIButton) in
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.contentEdgeInsets.left = Space.double
            button.contentEdgeInsets.right = Space.double

            let font = UIFont.dynamicBodySemibold
            let tintColor: UIColor = button.tintColor
            let cornerRadius = UIButton.Styles.cornerRadius

            let disabledBackgroundColor: UIColor
            if #available(iOS 13.0, *) {
                disabledBackgroundColor = .systemGray2
            } else {
                disabledBackgroundColor = .mousegrey
            }

            let colors: [(UIControl.State, foreground: UIColor, background: UIColor, backgroundImage: UIImage)] = [
                (.normal,
                 .inverse,
                 tintColor,
                 UIButton.Styles.roundedBackground(color: tintColor,
                                                  cornerRadius: cornerRadius)),
                (.highlighted,
                 .inverse,
                 .clear,
                 UIButton.Styles.roundedBackground(color: .highlighted(from: tintColor),
                                                   cornerRadius: cornerRadius)),
                (.disabled,
                 UIColor.AdaptiveColors.secondary,
                 .clear,
                 UIButton.Styles.roundedBackground(color: disabledBackgroundColor,
                                                   cornerRadius: cornerRadius)),
            ]
            colors.forEach { (state, foreground, background, backgroundImage) in
                guard let text = button.title(for: state) else { return }
                let attributedString = NSAttributedString(string: text, attributes: [
                    .foregroundColor: foreground,
                    .backgroundColor: background,
                    .font: font,
                ])
                button.setAttributedTitle(attributedString, for: state)
                button.setBackgroundImage(backgroundImage, for: state)
            }

            button.height.constraint(greaterThanOrEqualToConstant: 2 * Space.triple).isActive = true
        }

        /// Style for icon button.
        static let tintImage = InternalStyle(name: "button.dynamic.tintImage") { (button: UIButton) in
            let tintColor: UIColor = button.tintColor
            if let image = button.image(for: .normal) {
                button.setColorizedImage(image, color: tintColor, for: .normal)
                button.setColorizedImage(image, color: .highlighted(from: tintColor), for: .highlighted)
                button.setColorizedImage(image, color: .nobel, for: .disabled)
            }
        }

        /// Style for icon button.
        static let icon = tintImage + InternalStyle(name: "button.dynamic.icon") { (button: UIButton) in
            NSLayoutConstraint.activate([
                button.height.constraint(equalToConstant: Space.triple),
                button.width.constraint(equalTo: button.height),
            ])
        }

        /// Style for flat button.
        static let flat = InternalStyle(name: "button.dynamic.flat") { (button: UIButton) in
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.contentEdgeInsets.left = Space.double
            button.contentEdgeInsets.right = Space.double

            let font = UIFont.dynamicBodyMedium
            let tintColor: UIColor = button.tintColor

            let colors: [(UIControl.State, foreground: UIColor)] = [
                (.normal, tintColor),
                (.highlighted, .highlighted(from: tintColor)),
                (.disabled, .nobel),
            ]
            colors.forEach { (state, foreground) in
                guard let text = button.title(for: state) else { return }
                let attributedString = NSAttributedString(string: text, attributes: [
                    .foregroundColor: foreground,
                    .font: font,
                ])
                button.setAttributedTitle(attributedString, for: state)
            }

            button.height.constraint(greaterThanOrEqualToConstant: Space.fivefold).isActive = true
        }

        /// Style for link button.
        static let link = InternalStyle(name: "button.dynamic.link") { (button: UIButton) in
            button.titleLabel?.lineBreakMode = .byTruncatingTail

            let font = UIFont.dynamicBodyMedium
            let tintColor: UIColor = button.tintColor

            let colors: [(UIControl.State, UIColor)] = [
                (.normal, tintColor),
                (.highlighted, .highlighted(from: tintColor)),
                (.disabled, .nobel),
            ]

            colors.forEach { (state, textColor) in
                guard let text = button.title(for: state) else { return }
                let attributedString = NSAttributedString(string: text, attributes: [
                    .foregroundColor: textColor,
                    .font: font,
                ])
                button.setAttributedTitle(attributedString, for: state)
            }
        }
        
        /// Style for secondary link button.
        static let secondaryLink = InternalStyle(name: "button.dynamic.secondaryLink") { (button: UIButton) in
            button.titleLabel?.lineBreakMode = .byTruncatingTail

            let font = UIFont.dynamicBody
            let color = UIColor.doveGray

            let colors: [(UIControl.State, UIColor)] = [
                (.normal, color),
                (.highlighted, .highlighted(from: color)),
                (.disabled, .nobel),
            ]

            colors.forEach { (state, textColor) in
                guard let text = button.title(for: state) else { return }
                let attributedString = NSAttributedString(string: text, attributes: [
                    .foregroundColor: textColor,
                    .font: font,
                ])
                button.setAttributedTitle(attributedString, for: state)
            }
        }

        static let inverseLink = InternalStyle(name: "button.dynamic.inverseLink") { (button: UIButton) in
            button.titleLabel?.lineBreakMode = .byTruncatingTail

            let font = UIFont.dynamicBodyMedium

            let colors: [(UIControl.State, UIColor)] = [
                (.normal, .inverse),
                (.highlighted, .mousegrey),
                (.disabled, .nobel),
            ]

            colors.forEach { (state, textColor) in
                guard let text = button.title(for: state) else { return }
                let attributedString = NSAttributedString(string: text, attributes: [
                    .foregroundColor: textColor,
                    .font: font,
                ])
                button.setAttributedTitle(attributedString, for: state)
            }
        }

        static let iconLink = InternalStyle(name: "button.dynamic.iconLink") { (button: UIButton) in
            button.backgroundColor = .clear
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.contentEdgeInsets = UIEdgeInsets(top: Space.single,
                                                    left: 0,
                                                    bottom: Space.single,
                                                    right: 0)
            button.titleEdgeInsets.left = Space.single
            let tintColor: UIColor = button.tintColor

            let font = UIFont.dynamicBodyMedium
            let colors: [(UIControl.State, UIColor)] = [
                (.normal, tintColor),
                (.highlighted, .highlighted(from: tintColor)),
                (.disabled, .nobel),
                ]

            colors.forEach { (state, textColor) in
                guard let text = button.title(for: state),
                    let image = button.imageView?.image else { return }
                let attributedString = NSAttributedString(string: text, attributes: [
                    .foregroundColor: textColor,
                    .font: font,
                    ])
                button.setAttributedTitle(attributedString, for: state)
                if let imageForState = button.image(for: .normal) {
                    button.setColorizedImage(imageForState,
                                             color: textColor,
                                             for: state)
                }
            }
        }

        static let tag = InternalStyle(name: "button.dynamic.tag") { (button: UIButton) in
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.contentEdgeInsets.left = Space.single
            button.contentEdgeInsets.right = Space.single

            let font = UIFont.caption1
            let tintColor: UIColor = button.tintColor

            let colors: [(UIControl.State, foreground: UIColor, backgroundImage: UIImage)] = [
                (
                    .normal,
                    .inverse,
                    UIButton.Styles.roundedBackground(color: tintColor)
                ),
                (
                    .highlighted,
                    .inverse,
                    UIButton.Styles.roundedBackground(color: .highlighted(from: tintColor))
                ),
                (
                    .disabled,
                    .inverse,
                    UIButton.Styles.roundedBackground(color: .nobel)
                ),
                ]
            colors.forEach { (state, foreground, backgroundImage) in
                let attributedString = NSAttributedString(string: button.title(for: state) ?? "",
                                                          attributes: [
                    .foregroundColor: foreground,
                    .font: font,
                    ])
                button.setAttributedTitle(attributedString, for: state)
                button.setBackgroundImage(backgroundImage, for: state)
            }

            button.layer.cornerRadius = Constants.tagButtonHeight / 2
            button.clipsToBounds = true

            NSLayoutConstraint.activate([
                button.height.constraint(equalToConstant: Constants.tagButtonHeight),
            ])
        }

        static let small = InternalStyle(name: "dynamic.small") { (button: UIButton) in
            func makeCaption1String(_ string: NSAttributedString) -> NSAttributedString {
                let string = NSMutableAttributedString(attributedString: string)
                string.addAttributes([.font: UIFont.dynamicCaption1],
                                     range: NSRange(location: 0, length: string.length))
                return NSAttributedString(attributedString: string)
            }

            let titles: [(UIControl.State, NSAttributedString?)] = [
                (.normal, button.attributedTitle(for: .normal)),
                (.highlighted, button.attributedTitle(for: .highlighted)),
                (.disabled, button.attributedTitle(for: .disabled)),
                (.selected, button.attributedTitle(for: .selected)),
            ]

            for (state, title) in titles {
                button.setAttributedTitle(title.flatMap(makeCaption1String), for: state)
            }
        }
    }
}

// MARK: - Constants
private extension UIButton {
    enum Constants {
        static let tagButtonHeight: CGFloat = Space.triple
    }
}
