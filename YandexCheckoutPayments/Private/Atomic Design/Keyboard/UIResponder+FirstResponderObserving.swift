import UIKit.UIResponder

extension UIResponder {

    /// Current app first responder.
    @nonobjc
    private(set) static var currentFirstResponder: UIResponder?

    /// Flag to show if UIResponder need adittional setup before usage.
    @nonobjc
    private(set) static var needSetup = true

    static func setup() {
        _ = responderChangeSwizzling
        needSetup = false
    }

    @objc
    private func ym_becomeFirstResponder() -> Bool {
        guard UIResponder.currentFirstResponder !== self else { return self.ym_becomeFirstResponder() }

        // Need to change input accessory view before keyboard will appear.
        // So first responder is updated before call becomeFirstResponder().
        // Need to rollback if becomeFirstResponder return false.
        let oldResponder = UIResponder.currentFirstResponder
        KeyboardObservable.shared.reloadCurrentResponder(self)

        let isFirstResponder = self.ym_becomeFirstResponder()

        if isFirstResponder {
            UIResponder.currentFirstResponder = self
            // Need to call again.
            // In becomeFirstResponder() may be called resignFirstResponder() => reloadCurrentResponder(nil)
            KeyboardObservable.shared.reloadCurrentResponder(self)
        } else if UIResponder.currentFirstResponder == oldResponder {
            KeyboardObservable.shared.reloadCurrentResponder(oldResponder)
        }
        return isFirstResponder
    }

    @objc
    private func ym_resignFirstResponder() -> Bool {
        let isFirstResponder = self.ym_resignFirstResponder()
        if isFirstResponder && UIResponder.currentFirstResponder === self {
            KeyboardObservable.shared.reloadCurrentResponder(nil)
            UIResponder.currentFirstResponder = nil
        }
        return isFirstResponder
    }

    private static func swizzle(originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(UIResponder.self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(UIResponder.self, swizzledSelector)

        // swiftlint:disable force_unwrapping
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
        // swiftlint:enable force_unwrapping
    }

    private static var responderChangeSwizzling: Void = {
        let becomeOriginalSelector = #selector(becomeFirstResponder)
        let becomeSwizzledSelector = #selector(ym_becomeFirstResponder)
        swizzle(originalSelector: becomeOriginalSelector, swizzledSelector: becomeSwizzledSelector)

        let resignOriginalSelector = #selector(resignFirstResponder)
        let resignSwizzledSelector = #selector(ym_resignFirstResponder)
        swizzle(originalSelector: resignOriginalSelector, swizzledSelector: resignSwizzledSelector)

        return
    }()
}
