import UIKit

final class CellDescriptor {

    typealias CellType = UITableViewCell & TableViewCellDataProviderSupport

    let cellClass: CellType.Type
    let configuration: (UITableViewCell) -> Void
    let selection: ((IndexPath) -> Void)?

    init<Cell: CellType>(
        configuration: @escaping (Cell) -> Void,
        selection: ((IndexPath) -> Void)? = nil
    ) {
        self.cellClass = Cell.self
        self.selection = selection
        self.configuration = { cell in
            guard let cell = cell as? Cell else {
                assertionFailure("Cell and selection types mismatch")
                return
            }

            configuration(cell)
        }
    }
}
