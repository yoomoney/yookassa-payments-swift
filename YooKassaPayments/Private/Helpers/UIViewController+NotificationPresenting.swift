/* The MIT License
 *
 * Copyright © 2020 NBCO YooMoney LLC
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

@available(iOS 9.0, *)
extension UIViewController: NotificationPresenting {
    func present(_ notification: PresentableNotification) {
        switch notification.style {
        case .toast:
            presentToast(notification)
        case .alert:
            presentAlert(notification)
        }
    }

    private func presentToast(_ notification: PresentableNotification) {
        let notificationView = NotificationView()
        switch notification.type {
        case .error:
            notificationView.setStyles(NotificationView.Styles.error)
        case .info:
            notificationView.setStyles(NotificationView.Styles.info)
        case .success:
            notificationView.setStyles(NotificationView.Styles.success)
        }
        notificationView.message = notification.message
        let topAnchor = topLayoutGuide.bottomAnchor
        var bottomConstraint = notificationView.bottomAnchor.constraint(equalTo: topAnchor)
        notificationView.actions = notification.actions.map { action in
            return NotificationView.Action(title: action.title) { [weak self, weak notificationView] in
                NotificationCenter.default.post(name: action.notificationName, object: nil)
                if let notificationView = notificationView {
                    self?.closeNotificationView(notificationView, bottomConstraint: bottomConstraint)
                }
            }
        }
        insert(notificationView: notificationView)
        let constraints = [
            bottomConstraint,
            notificationView.leftAnchor.constraint(equalTo: view.leftAnchor),
            notificationView.rightAnchor.constraint(equalTo: view.rightAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
        view.layoutIfNeeded()
        bottomConstraint.isActive = false
        bottomConstraint = notificationView.topAnchor.constraint(equalTo: topAnchor)
        bottomConstraint.isActive = true
        UIView.animate(
            withDuration: Constants.showAnimationDuration,
            delay: 0,
            options: [UIView.AnimationOptions.curveEaseInOut],
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            },
            completion: { [weak self, weak notificationView] _ in
                guard notification.actions.isEmpty,
                      let notificationView = notificationView else { return }
                self?.closeNotificationView(
                    notificationView,
                    delay: Constants.presentationDuration,
                    bottomConstraint: bottomConstraint
                )
            }
        )
    }

    private func closeNotificationView(
        _ notificationView: NotificationView,
        delay: TimeInterval = 0,
        bottomConstraint: NSLayoutConstraint
    ) {
        let topAnchor = topLayoutGuide.bottomAnchor
        var bottomConstraint: NSLayoutConstraint = bottomConstraint
        bottomConstraint.isActive = false
        bottomConstraint = notificationView.bottomAnchor.constraint(equalTo: topAnchor)
        bottomConstraint.isActive = true
        UIView.animate(
            withDuration: Constants.hideAnimationDuration,
            delay: delay,
            options: [UIView.AnimationOptions.curveEaseInOut],
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            },
            completion: { _ in
                notificationView.removeFromSuperview()
            }
        )
    }

    private func presentAlert(
        _ notification: PresentableNotification
    ) {
        let alertController = UIAlertController(
            title: notification.title,
            message: notification.message,
            preferredStyle: .alert
        )
        let notificationActions = notification.actions.isEmpty
            ? [Action(title: CommonLocalized.Alert.cancel)]
            : notification.actions
        notificationActions.map { action in
            return UIAlertAction(title: action.title, style: .default) { _ in
                NotificationCenter.default.post(name: action.notificationName, object: nil)
            }
        }.forEach(alertController.addAction)
        present(alertController, animated: true)
    }

    func presentError(with message: String) {
        let notification = ToastAlertNotification(
            title: nil,
            message: message,
            type: .error,
            style: .toast,
            actions: []
        )
        present(notification)
    }

    func insert(notificationView: NotificationView) {
        if let navigationBar = navigationController?.navigationBar {
            view.insertSubview(notificationView, belowSubview: navigationBar)
        } else {
            view.addSubview(notificationView)
        }
    }
}

extension UIViewController {
    struct ToastAlertNotification: PresentableNotification {
        private(set) var title: String?
        private(set) var message: String
        private(set) var type: PresentableNotificationType
        private(set) var style: PresentableNotificationStyle
        private(set) var actions: [PresentableNotificationAction]
    }

    struct Action: PresentableNotificationAction {
        private(set) var title: String
    }
}

private extension UIViewController {
    enum Constants {
        static let showAnimationDuration: TimeInterval = 0.25
        static let hideAnimationDuration: TimeInterval = 0.18
        static let presentationDuration: TimeInterval = 2.75
    }
}
