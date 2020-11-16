import struct UIKit.UILayoutPriority

extension UILayoutPriority {

    static let highest = UILayoutPriority.required - 1
}

extension UILayoutPriority {
    static func + (left: UILayoutPriority, right: Float) -> UILayoutPriority {
        return UILayoutPriority(rawValue: left.rawValue + right)
    }

    static func - (left: UILayoutPriority, right: Float) -> UILayoutPriority {
        return UILayoutPriority(rawValue: left.rawValue - right)
    }
}
