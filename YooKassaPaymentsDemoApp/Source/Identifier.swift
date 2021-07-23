protocol Identifier {
    static var identifier: String { get }
}

extension Identifier {
    @nonobjc
    static var identifier: String {
        return String(describing: self)
    }
}
