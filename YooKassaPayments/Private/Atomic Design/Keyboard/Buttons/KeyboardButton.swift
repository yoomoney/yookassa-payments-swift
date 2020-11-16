import UIKit

/// Base keyboard button for keyboard view
class KeyboardButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    /// Button identifier
    var identifier = ""

    /// Button style
    var style = KeyboardButtonStyle() {
        didSet {
            setupBackgroundColor()

            setTitleColor(style.textColor, for: .normal)
            setTitleColor(style.selectedTextColor, for: .selected)
            setTitleColor(style.highlightedTextColor, for: .highlighted)

            titleLabel?.font = style.font
        }
    }

    // MARK: - Private properties

    fileprivate lazy var circleLayer: CAShapeLayer = {
        $0.fillColor = UIColor.clear.cgColor
        return $0
    }(CAShapeLayer())
}

// MARK: - Overridden
extension KeyboardButton {

    override func layoutSubviews() {
        super.layoutSubviews()

        if style.highlightedType == .circle {
            circleLayer.frame = bounds
            let diameter: CGFloat = 65
            let x = bounds.origin.x + (bounds.size.width - diameter) / 2
            let y = bounds.origin.y + (bounds.size.height - diameter) / 2
            let pathFrame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: diameter, height: diameter))
            let path = UIBezierPath(ovalIn: pathFrame)
            circleLayer.path = path.cgPath
        }
    }

    override var isHighlighted: Bool {
        didSet {
            setupBackgroundColor()
        }
    }
}

// MARK: - Internal methods
extension KeyboardButton {
    func setupBackgroundColor() {
        switch (isHighlighted, style.highlightedType) {
        case (true, .circle):
            circleLayer.fillColor = style.highlightedColor.cgColor
            backgroundColor = nil
        case (true, .fill):
            backgroundColor = style.highlightedColor
            circleLayer.fillColor = nil
        case (false, .circle):
            circleLayer.fillColor = style.backgroundColor.cgColor
            backgroundColor = nil
        case (false, .fill):
            backgroundColor = style.backgroundColor
            circleLayer.fillColor = nil
        }
    }
}

// MARK: - Private methods
private extension KeyboardButton {
    func setup() {
        layer.insertSublayer(circleLayer, below: imageView?.layer)
    }
}
