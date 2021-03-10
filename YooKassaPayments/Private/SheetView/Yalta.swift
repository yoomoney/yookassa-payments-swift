import UIKit

protocol LayoutItem { // `UIView`, `UILayoutGuide`
    var superview: UIView? { get }
}

extension UIView: LayoutItem {}
extension UILayoutGuide: LayoutItem {
    var superview: UIView? { return self.owningView }
}

extension LayoutItem { // Yalta methods available via `LayoutProxy`
    @nonobjc var al: LayoutProxy<Self> { return LayoutProxy(base: self) }
}

// MARK: - LayoutProxy

struct LayoutProxy<Base> {
    let base: Base
}

extension LayoutProxy where Base: LayoutItem {
    
    // MARK: SheetAnchors
    
    var top: SheetAnchor<SheetAnchorType.Edge, SheetAnchorAxis.Vertical> { return SheetAnchor(base, .top) }
    var bottom: SheetAnchor<SheetAnchorType.Edge, SheetAnchorAxis.Vertical> { return SheetAnchor(base, .bottom) }
    var left: SheetAnchor<SheetAnchorType.Edge, SheetAnchorAxis.Horizontal> { return SheetAnchor(base, .left) }
    var right: SheetAnchor<SheetAnchorType.Edge, SheetAnchorAxis.Horizontal> { return SheetAnchor(base, .right) }
    var leading: SheetAnchor<SheetAnchorType.Edge, SheetAnchorAxis.Horizontal> { return SheetAnchor(base, .leading) }
    var trailing: SheetAnchor<SheetAnchorType.Edge, SheetAnchorAxis.Horizontal> { return SheetAnchor(base, .trailing) }
    
    var centerX: SheetAnchor<SheetAnchorType.Center, SheetAnchorAxis.Horizontal> { return SheetAnchor(base, .centerX) }
    var centerY: SheetAnchor<SheetAnchorType.Center, SheetAnchorAxis.Vertical> { return SheetAnchor(base, .centerY) }
    
    var firstBaseline: SheetAnchor<SheetAnchorType.Baseline, SheetAnchorAxis.Vertical> { return SheetAnchor(base, .firstBaseline) }
    var lastBaseline: SheetAnchor<SheetAnchorType.Baseline, SheetAnchorAxis.Vertical> { return SheetAnchor(base, .lastBaseline) }
    
    var width: SheetAnchor<SheetAnchorType.Dimension, SheetAnchorAxis.Horizontal> { return SheetAnchor(base, .width) }
    var height: SheetAnchor<SheetAnchorType.Dimension, SheetAnchorAxis.Vertical> { return SheetAnchor(base, .height) }
    
    // MARK: SheetAnchor Collections
    
    func edges(_ edges: LayoutEdge...) -> SheetAnchorCollectionEdges { return SheetAnchorCollectionEdges(item: base, edges: edges) }
    var edges: SheetAnchorCollectionEdges { return SheetAnchorCollectionEdges(item: base, edges: [.left, .right, .bottom, .top]) }
    var center: SheetAnchorCollectionCenter { return SheetAnchorCollectionCenter(x: centerX, y: centerY) }
    var size: SheetAnchorCollectionSize { return SheetAnchorCollectionSize(width: width, height: height) }
}

extension LayoutProxy where Base: UIView {
    var margins: LayoutProxy<UILayoutGuide> { return base.layoutMarginsGuide.al }
    
    @available(iOS 11.0, tvOS 11.0, *)
    var safeArea: LayoutProxy<UILayoutGuide> { return base.safeAreaLayoutGuide.al }
}

// MARK: - SheetAnchors

// phantom types
enum SheetAnchorAxis {
    class Horizontal {}
    class Vertical {}
}

enum SheetAnchorType {
    class Dimension {}
    /// Includes `center`, `edge` and `baselines` anchors.
    class Alignment {}
    class Center: Alignment {}
    class Edge: Alignment {}
    class Baseline: Alignment {}
}

/// An anchor represents one of the view's layout attributes (e.g. `left`,
/// `centerX`, `width`, etc). Use the anchor’s methods to construct constraints.
struct SheetAnchor<Type, Axis> { // type and axis are phantom types
    internal let item: LayoutItem
    internal let attribute: NSLayoutConstraint.Attribute
    internal let offset: CGFloat
    internal let multiplier: CGFloat
    
    init(_ item: LayoutItem, _ attribute: NSLayoutConstraint.Attribute, offset: CGFloat = 0, multiplier: CGFloat = 1) {
        self.item = item; self.attribute = attribute; self.offset = offset; self.multiplier = multiplier
    }
    
    /// Returns a new anchor offset by a given amount.
    internal func offsetting(by offset: CGFloat) -> SheetAnchor<Type, Axis> {
        return SheetAnchor<Type, Axis>(item, attribute, offset: self.offset + offset, multiplier: self.multiplier)
    }
    
    /// Returns a new anchor with a given multiplier.
    internal func multiplied(by multiplier: CGFloat) -> SheetAnchor<Type, Axis> {
        return SheetAnchor<Type, Axis>(item, attribute, offset: self.offset * multiplier, multiplier: self.multiplier * multiplier)
    }
}

func + <Type, Axis>(anchor: SheetAnchor<Type, Axis>, offset: CGFloat) -> SheetAnchor<Type, Axis> {
    return anchor.offsetting(by: offset)
}

func - <Type, Axis>(anchor: SheetAnchor<Type, Axis>, offset: CGFloat) -> SheetAnchor<Type, Axis> {
    return anchor.offsetting(by: -offset)
}

func * <Type, Axis>(anchor: SheetAnchor<Type, Axis>, multiplier: CGFloat) -> SheetAnchor<Type, Axis> {
    return anchor.multiplied(by: multiplier)
}

// MARK: - SheetAnchors (SheetAnchorType.Alignment)

extension SheetAnchor where Type: SheetAnchorType.Alignment {
    /// Aligns two anchors.
    @discardableResult func align<Type: SheetAnchorType.Alignment>(with anchor: SheetAnchor<Type, Axis>, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        return Constraints.constrain(self, anchor, relation: relation)
    }
}

// MARK: - SheetAnchors (SheetAnchorType.Edge)

extension SheetAnchor where Type: SheetAnchorType.Edge {
    /// Pins the edge to the same edge of the superview.
    @discardableResult func pinToSuperview(inset: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        return _pin(to: item.superview!, attribute: attribute, inset: inset, relation: relation)
    }
    
    /// Pins the edge to the respected margin of the superview.
    @discardableResult func pinToSuperviewMargin(inset: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        return _pin(to: item.superview!, attribute: attribute.toMargin, inset: inset, relation: relation)
    }
    
    /// Pins the edge to the respected edges of the given container.
    @discardableResult func pin(to container: LayoutItem, inset: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        return _pin(to: container, attribute: attribute, inset: inset, relation: relation)
    }
    
    /// Pins the edge to the safe area of the view controller. Falls back to
    /// layout guides (`.topLayoutGuide` and `.bottomLayoutGuide` on iOS 10.
    @discardableResult func pinToSafeArea(of vc: UIViewController, inset: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        let item2: Any, attr2: NSLayoutConstraint.Attribute
        if #available(iOS 11, tvOS 11, *) {
            // Pin to `safeAreaLayoutGuide` on iOS 11
            (item2, attr2) = (vc.view.safeAreaLayoutGuide, self.attribute)
        } else {
            switch self.attribute {
            // Fall back to .topLayoutGuide and pin to it's .bottom.
            case .top: (item2, attr2) = (vc.topLayoutGuide, .bottom)
            // Fall back to .bottomLayoutGuide and pin to it's .top.
            case .bottom: (item2, attr2) = (vc.bottomLayoutGuide, .top)
                // There are no layout guides for .left and .right, so just pin
            // to the superview instead.
            default: (item2, attr2) = (vc.view!, self.attribute)
            }
        }
        return _pin(to: item2, attribute: attr2, inset: inset, relation: relation)
    }
    
    // Pin the anchor to another layout item.
    private func _pin(to item2: Any, attribute attr2: NSLayoutConstraint.Attribute, inset: CGFloat, relation: NSLayoutConstraint.Relation) -> NSLayoutConstraint {
        // Invert attribute and relation in certain cases. The `pin` semantics
        // are inspired by https://github.com/PureLayout/PureLayout
        let isInverted = [.trailing, .right, .bottom].contains(attribute)
        return Constraints.constrain(self, toItem: item2, attribute: attr2, offset: (isInverted ? -inset : inset), relation: (isInverted ? relation.inverted : relation))
    }
}

// MARK: - SheetAnchors (SheetAnchorType.Center)

extension SheetAnchor where Type: SheetAnchorType.Center {
    /// Aligns the axis with a superview axis.
    @discardableResult func alignWithSuperview(offset: CGFloat = 0, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        return align(with: SheetAnchor<Type, Axis>(self.item.superview!, self.attribute) + offset, relation: relation)
    }
}

// MARK: - SheetAnchors (SheetAnchorType.Dimension)

extension SheetAnchor where Type: SheetAnchorType.Dimension {
    /// Sets the dimension to a specific size.
    @discardableResult func set(_ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        return Constraints.constrain(item: item, attribute: attribute, relatedBy: relation, constant: constant)
    }
    
    @discardableResult func match<Axis>(_ anchor: SheetAnchor<SheetAnchorType.Dimension, Axis>, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        return Constraints.constrain(self, anchor, relation: relation)
    }
}

// MARK: - SheetAnchorCollectionEdges

struct SheetAnchorCollectionEdges {
    internal let item: LayoutItem
    internal let edges: [LayoutEdge]
    private var anchors: [SheetAnchor<SheetAnchorType.Edge, Any>] { return edges.map { SheetAnchor(item, $0.attribute) } }
    
    /// Pins the edges of the view to the edges of the superview so the the view
    /// fills the available space in a container.
    @discardableResult func pinToSuperview(insets: UIEdgeInsets = .zero, relation: NSLayoutConstraint.Relation = .equal) -> [NSLayoutConstraint] {
        return anchors.map { $0.pinToSuperview(inset: insets.inset(for: $0.attribute), relation: relation) }
    }
    
    /// Pins the edges of the view to the margins of the superview so the the view
    /// fills the available space in a container.
    @discardableResult func pinToSuperviewMargins(insets: UIEdgeInsets = .zero, relation: NSLayoutConstraint.Relation = .equal) -> [NSLayoutConstraint] {
        return anchors.map { $0.pinToSuperviewMargin(inset: insets.inset(for: $0.attribute), relation: relation) }
    }
    
    /// Pins the edges of the view to the edges of the given view so the the
    /// view fills the available space in a container.
    @discardableResult func pin(to item2: LayoutItem, insets: UIEdgeInsets = .zero, relation: NSLayoutConstraint.Relation = .equal) -> [NSLayoutConstraint] {
        return anchors.map { $0.pin(to: item2, inset: insets.inset(for: $0.attribute), relation: relation) }
    }
    
    /// Pins the edges to the safe area of the view controller.
    /// Falls back to layout guides on iOS 10.
    @discardableResult func pinToSafeArea(of vc: UIViewController, insets: UIEdgeInsets = .zero, relation: NSLayoutConstraint.Relation = .equal) -> [NSLayoutConstraint] {
        return anchors.map { $0.pinToSafeArea(of: vc, inset: insets.inset(for: $0.attribute), relation: relation) }
    }
}

// MARK: - SheetAnchorCollectionCenter

struct SheetAnchorCollectionCenter {
    internal let x: SheetAnchor<SheetAnchorType.Center, SheetAnchorAxis.Horizontal>
    internal let y: SheetAnchor<SheetAnchorType.Center, SheetAnchorAxis.Vertical>
    
    /// Centers the view in the superview.
    @discardableResult func alignWithSuperview() -> [NSLayoutConstraint] {
        return [x.alignWithSuperview(), y.alignWithSuperview()]
    }
    
    /// Makes the axis equal to the other collection of axis.
    @discardableResult func align(with anchors: SheetAnchorCollectionCenter) -> [NSLayoutConstraint] {
        return [x.align(with: anchors.x), y.align(with: anchors.y)]
    }
}


// MARK: - SheetAnchorCollectionSize

struct SheetAnchorCollectionSize {
    internal let width: SheetAnchor<SheetAnchorType.Dimension, SheetAnchorAxis.Horizontal>
    internal let height: SheetAnchor<SheetAnchorType.Dimension, SheetAnchorAxis.Vertical>
    
    /// Set the size of item.
    @discardableResult func set(_ size: CGSize, relation: NSLayoutConstraint.Relation = .equal) -> [NSLayoutConstraint] {
        return [width.set(size.width, relation: relation), height.set(size.height, relation: relation)]
    }
    
    /// Makes the size of the item equal to the size of the other item.
    @discardableResult func match(_ anchors: SheetAnchorCollectionSize, insets: CGSize = .zero, multiplier: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> [NSLayoutConstraint] {
        return [width.match(anchors.width * multiplier - insets.width, relation: relation),
                height.match(anchors.height * multiplier - insets.height, relation: relation)]
    }
}

// MARK: - Constraints

final class Constraints {
    var constraints = [NSLayoutConstraint]()
    
    /// All of the constraints created in the given closure are automatically
    /// activated at the same time. This is more efficient then installing them
    /// one-be-one. More importantly, it allows to make changes to the constraints
    /// before they are installed (e.g. change `priority`).
    @discardableResult init(_ closure: () -> Void) {
        Constraints._stack.append(self)
        closure() // create constraints
        Constraints._stack.removeLast()
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Creates and automatically installs a constraint.
    internal static func constrain(item item1: Any, attribute attr1: NSLayoutConstraint.Attribute, relatedBy relation: NSLayoutConstraint.Relation = .equal, toItem item2: Any? = nil, attribute attr2: NSLayoutConstraint.Attribute? = nil, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
        precondition(Thread.isMainThread, "Yalta APIs can only be used from the main thread")
        (item1 as? UIView)?.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: item1, attribute: attr1, relatedBy: relation, toItem: item2, attribute: attr2 ?? .notAnAttribute, multiplier: multiplier, constant: constant)
        _install(constraint)
        return constraint
    }
    
    /// Creates and automatically installs a constraint between two anchors.
    internal static func constrain<T1, A1, T2, A2>(_ lhs: SheetAnchor<T1, A1>, _ rhs: SheetAnchor<T2, A2>, offset: CGFloat = 0, multiplier: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        return constrain(item: lhs.item, attribute: lhs.attribute, relatedBy: relation, toItem: rhs.item, attribute: rhs.attribute, multiplier: (multiplier / lhs.multiplier) * rhs.multiplier, constant: offset - lhs.offset + rhs.offset)
    }
    
    /// Creates and automatically installs a constraint between an anchor and
    /// a given item.
    internal static func constrain<T1, A1>(_ lhs: SheetAnchor<T1, A1>, toItem item2: Any?, attribute attr2: NSLayoutConstraint.Attribute?, offset: CGFloat = 0, multiplier: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        return constrain(item: lhs.item, attribute: lhs.attribute, relatedBy: relation, toItem: item2, attribute: attr2, multiplier: multiplier / lhs.multiplier, constant: offset - lhs.offset)
    }
    
    private static var _stack = [Constraints]() // this is what enabled constraint auto-installing
    
    private static func _install(_ constraint: NSLayoutConstraint) {
        if _stack.isEmpty { // not creating a group of constraints
            constraint.isActive = true
        } else { // remember which constaints to install when group is completed
            let group = _stack.last!
            group.constraints.append(constraint)
        }
    }
}

// MARK: - UIView + Constraints

extension UIView {
    @discardableResult @nonobjc func addSubview(_ a: UIView, constraints: (LayoutProxy<UIView>) -> Void) -> Constraints {
        addSubview(a)
        return Constraints(for: a, constraints)
    }
    
    @discardableResult @nonobjc func addSubview(_ a: UIView, _ b: UIView, constraints: (LayoutProxy<UIView>, LayoutProxy<UIView>) -> Void) -> Constraints {
        [a, b].forEach { addSubview($0) }
        return Constraints(for: a, b, constraints)
    }
    
    @discardableResult @nonobjc func addSubview(_ a: UIView, _ b: UIView, _ c: UIView, constraints: (LayoutProxy<UIView>, LayoutProxy<UIView>, LayoutProxy<UIView>) -> Void) -> Constraints {
        [a, b, c].forEach { addSubview($0) }
        return Constraints(for: a, b, c, constraints)
    }
    
    @discardableResult @nonobjc func addSubview(_ a: UIView, _ b: UIView, _ c: UIView, _ d: UIView, constraints: (LayoutProxy<UIView>, LayoutProxy<UIView>, LayoutProxy<UIView>, LayoutProxy<UIView>) -> Void) -> Constraints {
        [a, b, c, d].forEach { addSubview($0) }
        return Constraints(for: a, b, c, d, constraints)
    }
}

// MARK: - Constraints (Arity)

extension Constraints {
    @discardableResult convenience init<A: LayoutItem>(for a: A, _ closure: (LayoutProxy<A>) -> Void) {
        self.init { closure(a.al) }
    }
    
    @discardableResult convenience init<A: LayoutItem, B: LayoutItem>(for a: A, _ b: B, _ closure: (LayoutProxy<A>, LayoutProxy<B>) -> Void) {
        self.init { closure(a.al, b.al) }
    }
    
    @discardableResult convenience init<A: LayoutItem, B: LayoutItem, C: LayoutItem>(for a: A, _ b: B, _ c: C, _ closure: (LayoutProxy<A>, LayoutProxy<B>, LayoutProxy<C>) -> Void) {
        self.init { closure(a.al, b.al, c.al) }
    }
    
    @discardableResult convenience init<A: LayoutItem, B: LayoutItem, C: LayoutItem, D: LayoutItem>(for a: A, _ b: B, _ c: C, _ d: D, _ closure: (LayoutProxy<A>, LayoutProxy<B>, LayoutProxy<C>, LayoutProxy<D>) -> Void) {
        self.init { closure(a.al, b.al, c.al, d.al) }
    }
}

// MARK: - Misc

enum LayoutEdge {
    case top, bottom, leading, trailing, left, right
    
    internal var attribute: NSLayoutConstraint.Attribute {
        switch self {
        case .top: return .top;          case .bottom: return .bottom
        case .leading: return .leading;  case .trailing: return .trailing
        case .left: return .left;        case .right: return .right
        }
    }
}

internal extension NSLayoutConstraint.Attribute {
    var toMargin: NSLayoutConstraint.Attribute {
        switch self {
        case .top: return .topMargin;           case .bottom: return .bottomMargin
        case .leading: return .leadingMargin;   case .trailing: return .trailingMargin
        case .left: return .leftMargin          case .right: return .rightMargin
        default: return self
        }
    }
}

internal extension NSLayoutConstraint.Relation {
    var inverted: NSLayoutConstraint.Relation {
        switch self {
        case .greaterThanOrEqual: return .lessThanOrEqual
        case .lessThanOrEqual: return .greaterThanOrEqual
        case .equal: return self
        @unknown default:
            return self
        }
    }
}

internal extension UIEdgeInsets {
    func inset(for attribute: NSLayoutConstraint.Attribute) -> CGFloat {
        switch attribute {
        case .top: return top; case .bottom: return bottom
        case .left, .leading: return left
        case .right, .trailing: return right
        default: return 0
        }
    }
}

// MARK: - Deprecated

extension SheetAnchor where Type: SheetAnchorType.Alignment {
    @available(*, deprecated, message: "Please use operators instead, e.g. `view.top.align(with: view.bottom * 2 + 10)`.")
    @discardableResult func align<Type: SheetAnchorType.Alignment>(with anchor: SheetAnchor<Type, Axis>, offset: CGFloat = 0, multiplier: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        return Constraints.constrain(self, anchor, offset: offset, multiplier: multiplier, relation: relation)
    }
}

extension SheetAnchor where Type: SheetAnchorType.Dimension {
    @available(*, deprecated, message: "Please use operators instead, e.g. `view.width.match(view.height * 2 + 10)`.")
    @discardableResult func match<Axis>(_ anchor: SheetAnchor<SheetAnchorType.Dimension, Axis>, offset: CGFloat = 0, multiplier: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
        return Constraints.constrain(self, anchor, offset: offset, multiplier: multiplier, relation: relation)
    }
}
