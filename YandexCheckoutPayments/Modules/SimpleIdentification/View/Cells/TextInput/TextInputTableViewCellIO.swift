protocol TextInputTableViewCellInput: class {
    var textControl: InputView { get }
    var errorText: String? { get }

    func showError()
    func hideError()
}

protocol TextInputTableViewCellOutput: TextControlDelegate {

}
