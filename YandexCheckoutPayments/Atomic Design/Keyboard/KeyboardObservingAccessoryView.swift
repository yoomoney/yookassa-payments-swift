import UIKit

/// Input accessory view with keyboard frame observing
class KeyboardObservingAccessoryView: UIView {

    var keyboardFrameChanged: ((CGRect) -> Void)?

    fileprivate var isActiveObserver = false
    fileprivate var frameObserveContext = 0
    fileprivate var centerObserveContext = 0

    deinit {
        removeObservers()
    }
}

// MARK: - Observing View-Related Changes
extension KeyboardObservingAccessoryView {
    override func willMove(toSuperview newSuperview: UIView?) {
        defer {
            super.willMove(toSuperview: newSuperview)
        }
        removeObservers()
        guard let newSuperview = newSuperview else {
            return
        }
        newSuperview.addObserver(self,
                                 forKeyPath: #keyPath(UIView.frame),
                                 options: .new,
                                 context: &frameObserveContext)
        newSuperview.addObserver(self,
                                 forKeyPath: #keyPath(UIView.center),
                                 options: .new,
                                 context: &centerObserveContext)
        isActiveObserver = true
    }
}

// MARK: - Managing Managed Objects
extension KeyboardObservingAccessoryView {
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard context == &frameObserveContext || context == &centerObserveContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        guard let frame = superview?.frame else { return }
        keyboardFrameChanged?(frame)
    }
}

// MARK: - Managing observers
private extension KeyboardObservingAccessoryView {
    func removeObservers() {
        if isActiveObserver, let superview = superview {
            superview.removeObserver(self, forKeyPath: #keyPath(UIView.frame), context: &frameObserveContext)
            superview.removeObserver(self, forKeyPath: #keyPath(UIView.center), context: &centerObserveContext)
            isActiveObserver = false
        }
    }
}
