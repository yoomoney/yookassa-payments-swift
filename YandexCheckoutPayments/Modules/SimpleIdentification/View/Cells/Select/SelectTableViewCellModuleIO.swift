import UIKit

protocol SelectTableViewCellModuleInput: class {

}

protocol SelectTableViewCellModuleOutput: class {
    func didPressSelect(cell: UITableViewCell)
}
