import UIKit

enum TextTableViewCellAssembly {

    static func makeModule(inputData: TextDisplayItem,
                           tableView: UITableView) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withType: TextTableViewCell.self)
        cell.configure(item: inputData)

        return cell
    }
}
