struct ErrorModuleInputData {
    let errorTitle: String
}

protocol ErrorModuleOutput: class {
    func didPressPlaceholderButton(on module: ErrorModuleInput)
}

protocol ErrorModuleInput {}
