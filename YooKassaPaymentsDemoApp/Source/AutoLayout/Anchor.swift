import UIKit.NSLayoutConstraint
import UIKit.UIView

class Anchor {
    fileprivate let view: Any
    fileprivate let attribute: NSLayoutConstraint.Attribute

    fileprivate init(view: Any, attribute: NSLayoutConstraint.Attribute) {
        self.view = view
        self.attribute = attribute
    }

    func constraint(equalTo anchor: Anchor) -> NSLayoutConstraint {
        return constraint(equalTo: anchor, constant: 0)
    }

    func constraint(equalTo anchor: Anchor, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view,
                                  attribute: attribute,
                                  relatedBy: .equal,
                                  toItem: anchor.view,
                                  attribute: anchor.attribute,
                                  multiplier: 1,
                                  constant: constant)
    }

    func constraint(greaterThanOrEqualTo anchor: Anchor) -> NSLayoutConstraint {
        return constraint(greaterThanOrEqualTo: anchor, constant: 0)
    }

    func constraint(greaterThanOrEqualTo anchor: Anchor, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view,
                                  attribute: attribute,
                                  relatedBy: .greaterThanOrEqual,
                                  toItem: anchor.view,
                                  attribute: anchor.attribute,
                                  multiplier: 1,
                                  constant: constant)
    }

    func constraint(lessThanOrEqualTo anchor: Anchor) -> NSLayoutConstraint {
        return constraint(lessThanOrEqualTo: anchor, constant: 0)
    }

    func constraint(lessThanOrEqualTo anchor: Anchor, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view,
                                  attribute: attribute,
                                  relatedBy: .lessThanOrEqual,
                                  toItem: anchor.view,
                                  attribute: anchor.attribute,
                                  multiplier: 1,
                                  constant: constant)
    }
}

class XAxisAnchor: Anchor {
}

class YAxisAnchor: Anchor {
}

class Dimension: Anchor {

    func constraint(equalTo anchor: Dimension, multiplier: CGFloat) -> NSLayoutConstraint {
        return constraint(equalTo: anchor, multiplier: multiplier, constant: 0)
    }

    func constraint(equalTo anchor: Dimension, multiplier: CGFloat, constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view,
                                  attribute: attribute,
                                  relatedBy: .equal,
                                  toItem: anchor.view,
                                  attribute: anchor.attribute,
                                  multiplier: multiplier,
                                  constant: constant)
    }

    func constraint(equalToConstant constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view,
                                  attribute: attribute,
                                  relatedBy: .equal,
                                  toItem: nil,
                                  attribute: .notAnAttribute,
                                  multiplier: 1,
                                  constant: constant)
    }

    func constraint(greaterThanOrEqualTo anchor: Dimension, multiplier: CGFloat) -> NSLayoutConstraint {
        return constraint(greaterThanOrEqualTo: anchor, multiplier: multiplier, constant: 0)
    }

    func constraint(greaterThanOrEqualTo anchor: Dimension,
                    multiplier: CGFloat,
                    constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view,
                                  attribute: attribute,
                                  relatedBy: .greaterThanOrEqual,
                                  toItem: anchor.view,
                                  attribute: anchor.attribute,
                                  multiplier: multiplier,
                                  constant: constant)
    }

    func constraint(greaterThanOrEqualToConstant constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view,
                                  attribute: attribute,
                                  relatedBy: .greaterThanOrEqual,
                                  toItem: nil,
                                  attribute: .notAnAttribute,
                                  multiplier: 1,
                                  constant: constant)
    }

    func constraint(lessThanOrEqualTo anchor: Dimension, multiplier: CGFloat) -> NSLayoutConstraint {
        return constraint(lessThanOrEqualTo: anchor, multiplier: multiplier, constant: 0)
    }

    func constraint(lessThanOrEqualTo anchor: Dimension,
                    multiplier: CGFloat,
                    constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view,
                                  attribute: attribute,
                                  relatedBy: .lessThanOrEqual,
                                  toItem: anchor.view,
                                  attribute: anchor.attribute,
                                  multiplier: multiplier,
                                  constant: constant)
    }

    func constraint(lessThanOrEqualToConstant constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view,
                                  attribute: attribute,
                                  relatedBy: .lessThanOrEqual,
                                  toItem: nil,
                                  attribute: .notAnAttribute,
                                  multiplier: 1,
                                  constant: constant)
    }
}

extension UIView {
    var left: XAxisAnchor {
        return XAxisAnchor(view: self, attribute: .left)
    }
    var right: XAxisAnchor {
        return XAxisAnchor(view: self, attribute: .right)
    }
    var top: YAxisAnchor {
        return YAxisAnchor(view: self, attribute: .top)
    }
    var bottom: YAxisAnchor {
        return YAxisAnchor(view: self, attribute: .bottom)
    }
    var leading: XAxisAnchor {
        return XAxisAnchor(view: self, attribute: .leading)
    }
    var trailing: XAxisAnchor {
        return XAxisAnchor(view: self, attribute: .trailing)
    }
    var width: Dimension {
        return Dimension(view: self, attribute: .width)
    }
    var height: Dimension {
        return Dimension(view: self, attribute: .height)
    }
    var centerX: XAxisAnchor {
        return XAxisAnchor(view: self, attribute: .centerX)
    }
    var centerY: YAxisAnchor {
        return YAxisAnchor(view: self, attribute: .centerY)
    }
    var lastBaseline: YAxisAnchor {
        return YAxisAnchor(view: self, attribute: .lastBaseline)
    }
    var firstBaseline: YAxisAnchor {
        return YAxisAnchor(view: self, attribute: .firstBaseline)
    }
    var leftMargin: XAxisAnchor {
        return XAxisAnchor(view: self, attribute: .leftMargin)
    }
    var rightMargin: XAxisAnchor {
        return XAxisAnchor(view: self, attribute: .rightMargin)
    }
    var topMargin: YAxisAnchor {
        return YAxisAnchor(view: self, attribute: .topMargin)
    }
    var bottomMargin: YAxisAnchor {
        return YAxisAnchor(view: self, attribute: .bottomMargin)
    }
    var leadingMargin: XAxisAnchor {
        return XAxisAnchor(view: self, attribute: .leadingMargin)
    }
    var trailingMargin: XAxisAnchor {
        return XAxisAnchor(view: self, attribute: .trailingMargin)
    }
    var centerXWithinMargins: XAxisAnchor {
        return XAxisAnchor(view: self, attribute: .centerXWithinMargins)
    }
    var centerYWithinMargins: YAxisAnchor {
        return YAxisAnchor(view: self, attribute: .centerYWithinMargins)
    }
}

extension UILayoutSupport {
    var top: YAxisAnchor {
        return YAxisAnchor(view: self, attribute: .top)
    }
    var bottom: YAxisAnchor {
        return YAxisAnchor(view: self, attribute: .bottom)
    }
    var height: Dimension {
        return Dimension(view: self, attribute: .height)
    }
}
