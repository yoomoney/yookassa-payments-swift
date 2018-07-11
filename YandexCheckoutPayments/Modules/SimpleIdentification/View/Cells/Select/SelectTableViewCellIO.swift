import UIKit

protocol SelectTableViewCellInput: class {

}

protocol SelectTableViewCellOutput {
    func selectDidPress(in cell: UITableViewCell)
}
