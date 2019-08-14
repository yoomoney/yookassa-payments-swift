struct LogoutConfirmationModuleInputData {
    let accountName: String
}

protocol LogoutConfirmationModuleInput: class {

}

protocol LogoutConfirmationModuleOutput: class {
    func logoutDidConfirm(on module: LogoutConfirmationModuleInput)
    func logoutDidCancel(on module: LogoutConfirmationModuleInput)
}
