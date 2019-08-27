import UIKit.UITableViewCell

extension UITableViewCell: Identifier {
    static func reuseIdentifier() -> String {
        return identifier
    }
}
