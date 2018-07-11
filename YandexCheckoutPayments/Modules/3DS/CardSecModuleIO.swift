struct CardSecModuleInputData {
    let requestUrl: String
    let redirectUrl: String

    init(requestUrl: String,
         redirectUrl: String) {
        self.requestUrl = requestUrl
        self.redirectUrl = redirectUrl
    }
}

protocol CardSecModuleInput: class {}

protocol CardSecModuleOutput: class {
    func didSuccessfullyPassedCardSec(on module: CardSecModuleInput)
    func didPressCloseButton(on module: CardSecModuleInput)
}
