import UIKit

@objc protocol KeyboardObserver: class { // Need objc to use in NSHashTable

    /// Keyboard will be shown.
    ///
    /// - Parameter keyboardInfo: keyboard notification info
    func keyboardWillShow(with keyboardInfo: KeyboardNotificationInfo)

    /// Keyboard was shown
    ///
    /// - Parameter keyboardInfo: keyboard notification info
    func keyboardDidShow(with keyboardInfo: KeyboardNotificationInfo)

    /// Keyboard will be hidden.
    ///
    /// - Parameter keyboardInfo: keyboard notification info
    func keyboardWillHide(with keyboardInfo: KeyboardNotificationInfo)

    /// Keyboard was hidden
    ///
    /// - Parameter keyboardInfo: keyboard notification info
    func keyboardDidHide(with keyboardInfo: KeyboardNotificationInfo)

    /// Keyboard did update frame.
    ///
    /// - Parameter keyboardFrame: current keyboard frame  in screen coordinates
    func keyboardDidUpdateFrame(_ keyboardFrame: CGRect)
}

/// Observe keyboard notifications (show / hide / change frame)
final class KeyboardObservable: NSObject { //NSObject to use kvo

    /// Shared instance of KeyboardObservable
    static let shared = KeyboardObservable()

    fileprivate var isObserving = false

    fileprivate var isReloadingResponder = false

    /// Responder view, which has input accessoryView observing keyboard
    fileprivate var currentObservingResponder: KeyboardResponder?

    fileprivate var inputAccessoryObserveContext = 0

    fileprivate var observers: NSHashTable<KeyboardObserver> = NSHashTable.weakObjects()

    private static let observersSyncLabel = "ru.yandex.mobile.money.queue.KeyboardObservable.subhandlersSync"

    /// Queue for synchronizations 'observers' property
    fileprivate let observersSync = DispatchQueue(label: KeyboardObservable.observersSyncLabel,
                                                  attributes: [.concurrent])

    /// Add observer to start receiving keyboard notifications in KeyboardObserver
    func addKeyboardObserver(_ observer: KeyboardObserver) {
        observersSync.sync(flags: .barrier) {
            self.observers.add(observer)
        }
        startObservingKeyboardIfNeeded()
    }

    /// Remove observer to stop receiving keyboard notifications in KeyboardObserver
    func removeKeyboardObserver(_ observer: KeyboardObserver) {
        var isEmpty = false
        observersSync.sync(flags: .barrier) {
            self.observers.remove(observer)
            isEmpty = self.observers.allObjects.isEmpty
        }
        if isEmpty {
            stopObservingKeyboardIfNeeded()
        }
    }

    /// Returns a Boolean value indicating whether the observer is subscribed to keyboard notifications
    func isSubscribed(_ observer: KeyboardObserver) -> Bool {
        var isContains = false
        observersSync.sync {
            isContains = observers.contains(observer)
        }
        return isContains
    }

    func reloadCurrentResponder(_ responder: UIResponder?) {
        guard responder !== currentObservingResponder else {
            return
        }
        isReloadingResponder = true
        if let observingResponder = currentObservingResponder {
            let observable = currentObservingResponder as? UIResponder
            observable?.removeObserver(self,
                                       forKeyPath: #keyPath(UIResponder.inputAccessoryView),
                                       context: &inputAccessoryObserveContext)

            removeObservingAccessoryView(fromResponder: observingResponder)
            currentObservingResponder = nil
        }

        if let responder = responder, let currentFirstResponder = responder as? KeyboardResponder {
            currentObservingResponder = currentFirstResponder
            addObservingAccessoryView(toResponder: currentFirstResponder)
            let observable = currentObservingResponder as? UIResponder
            observable?.addObserver(self,
                                    forKeyPath: #keyPath(UIResponder.inputAccessoryView),
                                    options: .new,
                                    context: &inputAccessoryObserveContext)
        }
        isReloadingResponder = false
    }
}

// MARK: - Manage KeyboardObservable notifications
private extension KeyboardObservable {
    func postNotifcation(_ notification: @escaping (KeyboardObserver) -> Void) {
        observersSync.sync {
            let enumerator = observers.objectEnumerator()
            while let observer = enumerator.nextObject() as? KeyboardObserver {
                DispatchQueue.main.async {
                    notification(observer)
                }
            }
        }
    }
}

// MARK: - Manage NotificationCenter notifications
private extension KeyboardObservable {

    func startObservingKeyboardIfNeeded() {
        guard isObserving == false else {
            return
        }
        let keyboardNotifications: [Notification.Name] = [
            UIResponder.keyboardWillShowNotification,
            UIResponder.keyboardDidShowNotification,
            UIResponder.keyboardWillHideNotification,
            UIResponder.keyboardDidHideNotification,
        ]
        keyboardNotifications.forEach {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleKeyboardNotification(_:)),
                                                   name: $0,
                                                   object: nil)
        }
        isObserving = true
    }

    func stopObservingKeyboardIfNeeded() {
        guard isObserving else {
            return
        }
        NotificationCenter.default.removeObserver(self)
        isObserving = false
    }

    @objc
    func handleKeyboardNotification(_ notification: Notification) {
        guard isObserving,
              isReloadingResponder == false,
              let userInfo = notification.userInfo,
              let keyboardInfo = parseNotificationUserInfo(userInfo) else {
            return
        }

        var isLocalUserInfoKey: Bool? = true
        if #available(iOS 9.0, *) {
            isLocalUserInfoKey = userInfo[UIResponder.keyboardIsLocalUserInfoKey] as? Bool
        }

        guard isLocalUserInfoKey == true else {
            return
        }

        let observerNotification: ((KeyboardObserver) -> Void)?
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            observerNotification = {
                $0.keyboardWillShow(with: keyboardInfo)
            }

        case UIResponder.keyboardDidShowNotification:
            observerNotification = {
                $0.keyboardDidShow(with: keyboardInfo)
            }

        case UIResponder.keyboardWillHideNotification:
            observerNotification = {
                $0.keyboardWillHide(with: keyboardInfo)
            }

        case UIResponder.keyboardDidHideNotification:
            observerNotification = {
                $0.keyboardDidHide(with: keyboardInfo)
            }

        default:
            observerNotification = nil
            break
        }

        if let observersNotificaion = observerNotification {
            postNotifcation(observersNotificaion)
        }
    }

    private func parseNotificationUserInfo(_ userInfo: [AnyHashable: Any]) -> KeyboardNotificationInfo? {
        guard let beginFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue).map({ $0.cgRectValue }),
              let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue).map({ $0.cgRectValue })
                else {
            return nil
        }
        let animationCurve
            = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int).flatMap(UIView.AnimationCurve.init)
        let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval)
        return KeyboardNotificationInfo(beginKeyboardFrame: beginFrame,
                                        endKeyboardFrame: endFrame,
                                        animationCurve: animationCurve,
                                        animationDuration: animationDuration)
    }
}

// MARK: - Input accessory view manage
private extension KeyboardObservable {
    func addObservingAccessoryView(toResponder responder: KeyboardResponder) {
        let observingAccessoryView = KeyboardObservingAccessoryView()
        observingAccessoryView.keyboardFrameChanged = { [weak self] keyboardFrame in

            guard let strongSelf = self,
                  strongSelf.isObserving,
                  strongSelf.isReloadingResponder == false,
                  strongSelf.currentObservingResponder === responder else {
                return
            }
            strongSelf.postNotifcation({ $0.keyboardDidUpdateFrame(keyboardFrame) })
        }

        if let accessoryView = responder.inputAccessoryView {
            responder.inputAccessoryView = observingAccessoryView
            observingAccessoryView.translatesAutoresizingMaskIntoConstraints = false
            observingAccessoryView.addSubview(accessoryView)
            NSLayoutConstraint.activate([
                accessoryView.top.constraint(equalTo: observingAccessoryView.top),
                accessoryView.leading.constraint(equalTo: observingAccessoryView.leading),
                accessoryView.trailing.constraint(equalTo: observingAccessoryView.trailing),
                accessoryView.bottom.constraint(equalTo: observingAccessoryView.bottom),
            ])
        } else {
            responder.inputAccessoryView = observingAccessoryView
        }

        responder.reloadInputViews()
    }

    func removeObservingAccessoryView(fromResponder responder: KeyboardResponder) {
        guard let accessoryView = responder.inputAccessoryView as? KeyboardObservingAccessoryView else { return }
        responder.inputAccessoryView = accessoryView.subviews.first
        responder.reloadInputViews()
    }
}

// MARK: - KVO
extension KeyboardObservable {
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard context == &inputAccessoryObserveContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if let responder = currentObservingResponder {
            addObservingAccessoryView(toResponder: responder)
        }
    }
}
