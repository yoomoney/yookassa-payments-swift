import UIKit

extension UIDevice {

    var isIphonePlus: Bool {
        if case .phone = UIDevice.current.userInterfaceIdiom,
           max(UIScreen.main.bounds.height, UIScreen.main.bounds.width) == 736 {
            return true
        }
        return false
    }
}
