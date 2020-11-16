import UIKit.UITableViewHeaderFooterView

extension UITableViewHeaderFooterView: Identifier {
    static func reuseIdentifier() -> String {
        return identifier
    }
}
