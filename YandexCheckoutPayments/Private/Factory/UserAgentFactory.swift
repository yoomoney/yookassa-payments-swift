import Foundation
import UIKit

private class Class { }

enum UserAgentFactory {
    static func makeHeaderValue() -> String {
        let frameworkVersion
            = Bundle(for: Class.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let osVersion = UIDevice.current.systemVersion
        let deviceClass: String

        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            deviceClass = "Phone"
        case .pad:
            deviceClass = "Tablet"
        default:
            deviceClass = "Unknown"
        }

        return ["Yandex.Checkout.SDK.iOS/", frameworkVersion, " iOS/", osVersion, " ", deviceClass].joined()
    }
}
