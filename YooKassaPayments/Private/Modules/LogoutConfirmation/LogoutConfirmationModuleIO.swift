struct LogoutConfirmationModuleInputData {
    let accountName: String
}

protocol LogoutConfirmationModuleInput: AnyObject {}

protocol LogoutConfirmationModuleOutput: AnyObject {
    func logoutDidConfirm(on module: LogoutConfirmationModuleInput)
    func logoutDidCancel(on module: LogoutConfirmationModuleInput)
}
