/*
 * The MIT License (MIT)
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

/// Custom activity indicator view
class ActivityIndicator: UIView {
    var strokeWidth: CGFloat {
        get {
            return spinnerLayer.lineWidth
        }
        set {
            spinnerLayer.lineWidth = newValue
        }
    }

    var spinnerSize: CGFloat {
        get {
            return spinnerLayer.path?.boundingBox.height ?? 0
        }
        set {
            guard newValue != spinnerSize else { return }
            invalidateIntrinsicContentSize()
            spinnerLayer.path = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                             radius: newValue / 2,
                                             startAngle: 0,
                                             endAngle: CGFloat.pi,
                                             clockwise: false).cgPath
        }
    }

    var spinnerColor: UIColor? {
        get {
            return spinnerLayer.strokeColor.map(UIColor.init)
        }
        set {
            spinnerLayer.strokeColor = newValue?.cgColor
        }
    }

    override var backgroundColor: UIColor? {
        didSet {
            spinnerLayer.fillColor = backgroundColor?.cgColor
        }
    }

    fileprivate let spinnerAnimation: CAAnimation = {
        let infiniteClockwiseRotation = CABasicAnimation(keyPath: "transform.rotation.z")
        infiniteClockwiseRotation.fromValue = 0
        infiniteClockwiseRotation.toValue = 2 * CGFloat.pi
        infiniteClockwiseRotation.duration = 1
        infiniteClockwiseRotation.repeatCount = Float.infinity
        infiniteClockwiseRotation.isRemovedOnCompletion = false
        return infiniteClockwiseRotation
    }()

    fileprivate lazy var spinnerLayer: CAShapeLayer = {
        guard let layer = self.layer as? CAShapeLayer else {
            assertionFailure("layer is not CAShapeLayer")
            return CAShapeLayer()
        }
        return layer
    }()

    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func startAnimating() {
        isHidden = false
        spinnerLayer.add(spinnerAnimation, forKey: "spinnerAnimation")
    }

    func stopAnimating() {
        spinnerLayer.removeAnimation(forKey: "spinnerAnimation")
        isHidden = true
    }

    // MARK: - TintColor actions

    override func tintColorDidChange() {
        applyStyles()
    }
}

// MARK: - Private
private extension ActivityIndicator {
    func setupView() {
        isHidden = true
        spinnerLayer.fillColor = UIColor.clear.cgColor
    }
}
