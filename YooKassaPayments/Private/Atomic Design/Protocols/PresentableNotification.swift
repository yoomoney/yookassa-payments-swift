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

import Foundation

/// Action for `PresentableNotification`.
///
/// In default implementation of `present(_:)` this send `notificationName` through
/// `NotificationCenter.default`.
protocol PresentableNotificationAction {
    var title: String { get }
}

extension PresentableNotificationAction {
    var signal: String {
        return String(reflecting: self)
    }

    var notificationName: Notification.Name {
        return Notification.Name(rawValue: "ErrorPresentationAction.signal.\(signal)")
    }
}

/// Style of notification.
enum PresentableNotificationStyle {
    /// The notification will be appear under the navigation bar or the status bar.
    case toast
    /// Tha notification will be appear in the alert.
    case alert
}

/// Type of notification.
enum PresentableNotificationType {
    /// The notification is a error.
    case error
    /// The notification is a message about success.
    case success
    /// The notification is a additional info.
    case info
}

protocol PresentableNotification {
    /// Title of notification. Used in style `.alert`.
    var title: String? { get }
    /// Message of notification.
    var message: String { get }
    /// Notification type.
    var type: PresentableNotificationType { get }
    /// Notification style.
    var style: PresentableNotificationStyle { get }
    /// Notification actions.
    var actions: [PresentableNotificationAction] { get }
}
