import UIKit.UITableView
import UIKit.UITableViewCell
import UIKit.UITableViewHeaderFooterView

extension UITableView {

    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(T.self, forCellReuseIdentifier: T.identifier)
    }

    func register<T: UITableViewHeaderFooterView>(_ headerFooterViewClass: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.identifier)
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(withType type: T.Type) -> T {
        // swiftlint:disable:next force_cast
        return dequeueReusableHeaderFooterView(withIdentifier: type.identifier) as! T
    }

    func dequeueReusableCell<T: UITableViewCell>(withType type: T.Type,
                                                 for indexPath: IndexPath) -> T {
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withIdentifier: type.identifier, for: indexPath) as! T
    }

    func dequeueReusableCell<T: UITableViewCell>(withType type: T.Type) -> T {
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withIdentifier: type.identifier) as! T
    }

}
