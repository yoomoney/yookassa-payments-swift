protocol SimpleIdentificationViewInput: class {
    func setTitle(_ title: String)
    func setDisplayItems(_ items: [ShowcaseDisplayItem])
    func setSubmitItem(_ item: SubmitDisplayItem)
    func updateDisplayItem(_ item: ShowcaseDisplayItem, at index: Int)
    func showError(_ error: String)
}

protocol SimpleIdentificationViewOutput {
    func viewDidLoad()
    func selectOption(_ option: SelectOptionDisplayItem, at index: Int)
    func changedInputText(_ text: String, valid: Bool, at index: Int)
    func submitDidPress()
    func closeDidPress()
}
