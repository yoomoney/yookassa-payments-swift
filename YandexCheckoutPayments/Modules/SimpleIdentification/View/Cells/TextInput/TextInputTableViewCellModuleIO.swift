import UIKit

protocol TextInputTableViewCellModuleInput: class {

}

protocol TextInputTableViewCellModuleOutput: class {
    func needLayoutUpdate()
    func textInput(cell: UITableViewCell, didChangeText text: String, valid: Bool)
}
