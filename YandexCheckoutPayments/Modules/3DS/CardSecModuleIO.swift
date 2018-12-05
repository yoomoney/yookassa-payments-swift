struct CardSecModuleInputData {
    let requestUrl: String
    let redirectUrl: String
    let isLoggingEnabled: Bool

    init(requestUrl: String,
         redirectUrl: String,
         isLoggingEnabled: Bool) {
        self.requestUrl = requestUrl
        self.redirectUrl = redirectUrl
        self.isLoggingEnabled = isLoggingEnabled
    }
}

protocol CardSecModuleInput: class {}

protocol CardSecModuleOutput: class {
    func didSuccessfullyPassedCardSec(on module: CardSecModuleInput)
    func didPressCloseButton(on module: CardSecModuleInput)
}
