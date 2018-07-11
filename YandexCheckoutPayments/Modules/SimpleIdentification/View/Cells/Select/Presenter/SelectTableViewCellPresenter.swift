import UIKit

final class SelectTableViewCellPresenter {

    weak var output: SelectTableViewCellModuleOutput?
}

extension SelectTableViewCellPresenter: SelectTableViewCellOutput {

    func selectDidPress(in cell: UITableViewCell) {
        output?.didPressSelect(cell: cell)
    }
}
