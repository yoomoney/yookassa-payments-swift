extension UITextField: InputView {
    var inputText: String? {
        get {
            return text
        }
        set {
            text = newValue
        }
    }

}
