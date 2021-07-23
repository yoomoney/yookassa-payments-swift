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

extension TextControl {

    class Layout {

        private unowned var control: TextControl

        var padding: UIEdgeInsets = .zero {
            didSet {
                paddingTopConstraint.constant = padding.top
                paddingTrailingConstraint.constant = -padding.right
                paddingBottomConstraint.constant = -padding.bottom
                paddingLeadingConstraint.constant = padding.left
            }
        }

        private let paddingTopConstraint: NSLayoutConstraint
        private let paddingTrailingConstraint: NSLayoutConstraint
        private let paddingBottomConstraint: NSLayoutConstraint
        private let paddingLeadingConstraint: NSLayoutConstraint

        private let paddingDummyView: UIView

        private(set) lazy var topHintConstraints: [NSLayoutConstraint] = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
            return [
                $0.leading.constraint(equalTo: $1.leading),
                $0.trailing.constraint(equalTo: $1.trailing),
                $0.top.constraint(equalTo: $1.top, constant: Constants.TopHint.top),
                $0.bottom.constraint(equalTo: $2.top, constant: -Constants.TopHint.bottom),
            ]
        }(self.control.topHintLabel, self.paddingDummyView, self.control.textView)

        private(set) lazy var bottomHintConstraints: [NSLayoutConstraint] = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
            return [
                $0.leading.constraint(equalTo: $1.leading),
                $0.trailing.constraint(equalTo: $1.trailing),
                $0.bottom.constraint(equalTo: $1.bottom, constant: -Constants.BottomHint.bottom),
                $0.top.constraint(equalTo: $2.top, constant: Constants.BottomHint.top),
            ]
        }(self.control.bottomHintLabel, self.paddingDummyView, self.control.lineView)

        private(set) lazy var rightButtonConstraints: [NSLayoutConstraint] = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            return [
                $0.leading.constraint(equalTo: $2.trailing, constant: Constants.RightButton.leading),
                $0.trailing.constraint(equalTo: $1.trailing),
                $0.centerY.constraint(equalTo: $2.centerY),
                $0.width.constraint(equalToConstant: Constants.RightButton.width),
                $0.height.constraint(equalToConstant: Constants.RightButton.height),
            ]
        }(self.control.rightButton, self.paddingDummyView, self.control.textView)

        private(set) lazy var clearButtonConstraints: [NSLayoutConstraint] = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            return [
                $0.leading.constraint(equalTo: $2.trailing, constant: Constants.ClearButton.leading),
                $0.trailing.constraint(equalTo: $1.trailing),
                $0.centerY.constraint(equalTo: $2.centerY),
                $0.width.constraint(equalToConstant: Constants.ClearButton.width),
                $0.height.constraint(equalToConstant: Constants.ClearButton.height),
            ]
        }(self.control.clearButton, self.paddingDummyView, self.control.textView)

        private(set) lazy var placeholderConstraints: [NSLayoutConstraint] = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            return [
                $0.leading.constraint(equalTo: $1.leading),
                $0.trailing.constraint(equalTo: $1.trailing),
                $0.top.constraint(equalTo: $1.top),
                $0.bottom.constraint(equalTo: $1.bottom),
            ]
        }(self.control.placeholderLabel, self.control.textView)

        private(set) lazy var leftIconConstraints: [NSLayoutConstraint] = {

            control.leftIcon.translatesAutoresizingMaskIntoConstraints = false

            control.leftIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
            control.leftIcon.setContentCompressionResistancePriority(.required, for: .vertical)

            return [
                control.textView.leading.constraint(equalTo: control.leftIcon.trailing,
                                                    constant: Constants.LeftIcon.trailing),
                control.leftIcon.leading.constraint(equalTo: paddingDummyView.leading),
                control.leftIcon.centerY.constraint(equalTo: control.textView.centerY),
                control.leftIcon.width.constraint(equalTo: control.leftIcon.height),
            ]
        }()

        private(set) lazy var topHintConstraintsWithLeftIcon: [NSLayoutConstraint] = {

            control.topHintLabel.translatesAutoresizingMaskIntoConstraints = false
            control.topHintLabel.setContentCompressionResistancePriority(.required, for: .vertical)

            let textViewTopConstraint = control.textView.top
                .constraint(greaterThanOrEqualTo: control.topHintLabel.bottom, constant: Space.single)
            textViewTopConstraint.priority = .required

            return [
                control.topHintLabel.leading.constraint(equalTo: paddingDummyView.leading),
                control.topHintLabel.trailing.constraint(equalTo: paddingDummyView.trailing),
                control.topHintLabel.top.constraint(equalTo: paddingDummyView.top, constant: Constants.TopHint.top),
                textViewTopConstraint,
            ]
        }()

        // MARK: - Accessibility constraints support

        private(set) lazy var accessibilityTopHintConstraintsWithLeftIcon: [NSLayoutConstraint] = {

            control.topHintLabel.translatesAutoresizingMaskIntoConstraints = false
            control.topHintLabel.setContentCompressionResistancePriority(.required, for: .vertical)

            return [
                control.topHintLabel.leading.constraint(equalTo: paddingDummyView.leading),
                control.topHintLabel.trailing.constraint(equalTo: paddingDummyView.trailing),
                control.topHintLabel.top.constraint(equalTo: paddingDummyView.top, constant: Constants.TopHint.top),
                control.leftIcon.top.constraint(equalTo: control.topHintLabel.bottom,
                                                constant: Constants.TopHint.bottom),
            ]
        }()

        private(set) lazy var accessibilityLeftIconConstraints: [NSLayoutConstraint] = {

            control.leftIcon.translatesAutoresizingMaskIntoConstraints = false

            control.leftIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
            control.leftIcon.setContentCompressionResistancePriority(.required, for: .vertical)

            return [
                control.textView.top.constraint(equalTo: control.leftIcon.bottom, constant: Constants.LeftIcon.bottom),
                control.leftIcon.top.constraint(greaterThanOrEqualTo: paddingDummyView.top,
                                                constant: Constants.LeftIcon.top),
                control.leftIcon.leading.constraint(equalTo: paddingDummyView.leading),
                control.leftIcon.width.constraint(equalTo: control.leftIcon.height),
            ]
        }()

        // MARK: - Initializers & deinitializer

        init(control: TextControl) {

            self.control = control

            ([control.textView, control.lineView] as [UIView]).forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
            }

            paddingDummyView = UIView()
            paddingDummyView.translatesAutoresizingMaskIntoConstraints = false
            control.insertSubview(paddingDummyView, at: 0)

            let minTopConstraint = control.textView.top.constraint(equalTo: paddingDummyView.top,
                                                                   constant: Constants.TextView.top)
            minTopConstraint.priority = .defaultHigh
            let minBottomConstraint =
                control.lineView.bottom.constraint(equalTo: paddingDummyView.bottom,
                                                   constant: -Constants.LineView.bottom)
            minBottomConstraint.priority = .defaultHigh

            let textViewTrailingConstraint =
                control.textView.trailing.constraint(equalTo: paddingDummyView.trailing)
            textViewTrailingConstraint.priority = .defaultHigh

            let textViewLeadingConstraint =
                control.textView.leading.constraint(equalTo: paddingDummyView.leading)
            textViewLeadingConstraint.priority = .defaultHigh

            paddingTopConstraint = paddingDummyView.top.constraint(equalTo: control.top,
                                                                   constant: padding.top)
            paddingTrailingConstraint = paddingDummyView.trailing.constraint(equalTo: control.trailing,
                                                                             constant: -padding.right)
            paddingBottomConstraint = paddingDummyView.bottom.constraint(equalTo: control.bottom,
                                                                         constant: -padding.bottom)
            paddingLeadingConstraint = paddingDummyView.leading.constraint(equalTo: control.leading,
                                                                           constant: padding.left)

            let lineViewTopConstraint = control.lineView.top.constraint(equalTo: control.textView.bottom,
                                                                        constant: Constants.TextView.bottom)
            lineViewTopConstraint.priority = .defaultHigh

            let constraints: [NSLayoutConstraint] = [
                paddingTopConstraint,
                paddingTrailingConstraint,
                paddingBottomConstraint,
                paddingLeadingConstraint,

                minTopConstraint,
                minBottomConstraint,
                textViewTrailingConstraint,
                textViewLeadingConstraint,
                lineViewTopConstraint,

                control.lineView.leading.constraint(equalTo: paddingDummyView.leading),
                control.lineView.trailing.constraint(equalTo: paddingDummyView.trailing),
                control.lineView.height.constraint(equalToConstant: Constants.LineView.height),
            ]

            NSLayoutConstraint.activate(constraints)
        }
    }
}

private extension TextControl.Layout {
    enum Constants {
        enum TopHint {
            static let top: CGFloat = 16
            static let bottom: CGFloat = 4
        }
        enum BottomHint {
            static let top: CGFloat = 8
            static let bottom: CGFloat = Space.single
        }
        enum RightButton {
            static let leading: CGFloat = 4
            static let width: CGFloat = 24
            static let height: CGFloat = 24
        }
        enum ClearButton {
            static let leading: CGFloat = 4
            static let width: CGFloat = 24
            static let height: CGFloat = 24
        }
        enum TextView {
            static let top: CGFloat = 35
            static let bottom: CGFloat = 8

        }
        enum LineView {
            static let bottom: CGFloat = 0
            static let height: CGFloat = 1
        }
        enum LeftIcon {
            static let top: CGFloat = 4
            static let bottom: CGFloat = 4
            static let trailing: CGFloat = Space.single
        }
    }
}
