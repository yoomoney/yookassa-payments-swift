import CoreGraphics

enum Space {
    static let single: CGFloat = 8
    static let double: CGFloat = 16
    static let triple: CGFloat = 24
    static let quadruple: CGFloat = 32
    static let fivefold: CGFloat = 40
}

extension Space {
    static var metrics: [String: Any] {
        return [
            "single": Space.single,
            "double": Space.double,
            "triple": Space.triple,
            "quadruple": Space.quadruple,
            "fivefold": Space.fivefold,
        ]
    }
}
