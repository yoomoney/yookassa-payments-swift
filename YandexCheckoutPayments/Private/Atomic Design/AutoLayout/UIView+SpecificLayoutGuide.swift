import class UIKit.UIView
import class UIKit.UILayoutGuide

extension UIView {

    /// Returns the correct layout guide.
    @available(iOS 9.0, *)
    var specificLayoutGuide: UILayoutGuide {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide
        } else {
            return layoutMarginsGuide
        }
    }
}
