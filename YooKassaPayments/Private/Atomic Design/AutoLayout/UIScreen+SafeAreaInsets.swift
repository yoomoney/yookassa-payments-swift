import UIKit

extension UIScreen {
    static var safeAreaInsets: UIEdgeInsets {
        guard let rootView = UIApplication.shared.keyWindow else { return .zero }

        if #available(iOS 11.0, *) {
            return rootView.safeAreaInsets
        } else {
            return .zero
        }
    }
}
