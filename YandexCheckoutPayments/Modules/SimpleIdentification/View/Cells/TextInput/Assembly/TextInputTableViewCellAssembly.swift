import UIKit

enum TextInputTableViewCellAssembly {

    static func makeModule(inputData: TextInputDisplayItem,
                           tableView: UITableView,
                           moduleOutput: TextInputTableViewCellModuleOutput?) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withType: TextInputTableViewCell.self)

        let style = TextInputPresenterStyleFactory.makeInputStyle(inputData)
        let validator = TextInputValidatorFactory.makeValidator(inputData)
        let outputFormatter = TextInputOutputFormatterFactory.makeOutputFormatter(inputData)

        let presenter = TextInputTableViewCellPresenter(inputStyle: style,
                                                        validator: validator,
                                                        outputFormatter: outputFormatter)

        presenter.view = cell
        presenter.output = moduleOutput

        cell.output = presenter
        cell.configure(item: inputData)

        return cell
    }
}
