/* The MIT License
 *
 * Copyright © 2022 NBCO YooMoney LLC
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

    /// Line view for the text control
    final class LineView: UIView {

        private lazy var lineLayer: CAShapeLayer = {
            let clearColor = UIColor.clear.cgColor
            $0.backgroundColor = clearColor
            $0.fillColor = clearColor
            $0.strokeEnd = 0
            return $0
        }(CAShapeLayer())

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setup()
        }

        /// State of the line view
        var state: State {
            get {
                guard lineLayer.strokeEnd == 1,
                    let strokeColor = lineLayer.strokeColor else {
                    return .clear
                }
                return .filled(color: UIColor(cgColor: strokeColor),
                               height: lineLayer.lineWidth)
            }
            set (state) {
                switch state {
                case let .filled(color, height):
                    fillLine(with: color, height: height, animated: false)
                case .clear:
                    hideLine(animated: false)
                }
            }
        }

        /// Fill the line
        ///
        /// - Parameters:
        ///   - color: Color of the line
        ///   - height: Height of the line
        ///   - animated: Set this value to true to animate the transition
        func fillLine(with color: UIColor, height: CGFloat, animated: Bool = true) {
            lineLayer.lineWidth = height
            lineLayer.strokeColor = color.cgColor
            lineLayer.strokeEnd = 0
            if animated {
                animateLine(to: 1)
            } else {
                lineLayer.strokeEnd = 1
            }
        }

        /// Hide the line
        ///
        /// - Parameter animated: Set this value to true to animate the transition
        func hideLine(animated: Bool = true) {
            if animated {
                animateLine(to: 0)
            } else {
                lineLayer.strokeEnd = 0
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            updatePath()
        }

        private func setup() {
            layer.addSublayer(lineLayer)
        }

        private func animateLine(to value: CGFloat) {
            transactionAnimation(with: Constants.Animation.duration,
                                 timingFuncion: Constants.Animation.timingCurve) {
                self.lineLayer.strokeEnd = value
            }
        }

        private func updatePath() {
            let path = UIBezierPath()
            let initialPoint = CGPoint(x: 0, y: bounds.midY)
            let finalPoint = CGPoint(x: bounds.maxX, y: bounds.midY)
            path.move(to: initialPoint)
            path.addLine(to: finalPoint)
            lineLayer.path = path.cgPath
        }
    }
}

extension TextControl.LineView {

    /// State of the line view
    ///
    /// - filled: Filled with color and height
    /// - clear: No line filling
    enum State {

        /// Filled line with color and height
        case filled(color: UIColor, height: CGFloat)

        /// No line filling
        case clear

        /// Default state is clear
        static let `default`: State = .clear
    }
}

extension TextControl.LineView.State: Equatable {
    static func == (lhs: TextControl.LineView.State, rhs: TextControl.LineView.State) -> Bool {
        switch (lhs, rhs) {
        case (.clear, .clear):
            return true
        case (let .filled(lc, lh), let .filled(rc, rh))
            where lc == rc && lh == rh:
            return true
        default:
            return false
        }
    }
}

extension TextControl.LineView {
    enum Constants {
        enum Animation {
            static let timingCurve = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1)
            static let duration: CFTimeInterval = 0.12
        }
    }
}
