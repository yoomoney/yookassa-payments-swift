typealias SberbankModuleInputData = ContractModuleInputData

protocol SberbankModuleInput: ContractStateHandler { }

protocol SberbankModuleOutput: class {
    func sberbank(_ module: SberbankModuleInput,
                  phoneNumber: String)
    func didFinish(on module: SberbankModuleInput)
    func didPressChangeAction(on module: SberbankModuleInput)
}
