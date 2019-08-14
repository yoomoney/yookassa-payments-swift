import UIKit

typealias ShowcaseCellModuleOutput = TextInputTableViewCellModuleOutput &
                                     SelectTableViewCellModuleOutput

enum ShowcaseCellModuleFactory {

    static func makeShowcaseCellModuleForm(_ item: ShowcaseDisplayItem,
                                           in tableView: UITableView,
                                           moduleOutput: ShowcaseCellModuleOutput) -> UITableViewCell {

        let cell: UITableViewCell

        switch item {
        case .input(let item):
            cell = TextInputTableViewCellAssembly.makeModule(inputData: item,
                                                             tableView: tableView,
                                                             moduleOutput: moduleOutput)
        case .text(let item):
            cell = TextTableViewCellAssembly.makeModule(inputData: item, tableView: tableView)

        case .select(let item, let option):
            cell = SelectTableViewCellAssembly.makeModule(inputData: item,
                                                          option: option,
                                                          tableView: tableView,
                                                          moduleOutput: moduleOutput)
        }

        return cell
    }
}
