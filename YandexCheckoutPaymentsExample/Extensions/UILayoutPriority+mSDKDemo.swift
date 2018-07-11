import UIKit

extension UILayoutPriority {

    func with(delta: Float) -> UILayoutPriority {
        return UILayoutPriority(self.rawValue + delta)
    }

}
