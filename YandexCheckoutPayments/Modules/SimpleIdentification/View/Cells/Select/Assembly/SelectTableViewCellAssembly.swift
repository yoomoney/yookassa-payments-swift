import UIKit

enum SelectTableViewCellAssembly {

    static func makeModule(inputData: SelectDisplayItem,
                           option: SelectOptionDisplayItem?,
                           tableView: UITableView,
                           moduleOutput: SelectTableViewCellModuleOutput?) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withType: SelectTableViewCell.self)
        let presenter = SelectTableViewCellPresenter()

        presenter.output = moduleOutput

        cell.output = presenter
        cell.configure(item: inputData)
        cell.setLocalizedValue(option?.label)

        return cell
    }
}
