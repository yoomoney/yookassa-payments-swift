struct CardSecModuleInputData {

    // MARK: - Init data

    let requestUrl: String
    let redirectUrl: String
    let isLoggingEnabled: Bool

    // MARK: - Init

    init(
        requestUrl: String,
        redirectUrl: String,
        isLoggingEnabled: Bool
    ) {
        self.requestUrl = requestUrl
        self.redirectUrl = redirectUrl
        self.isLoggingEnabled = isLoggingEnabled
    }
}

protocol CardSecModuleInput: AnyObject {}

protocol CardSecModuleOutput: AnyObject {
    func didSuccessfullyPassedCardSec(on module: CardSecModuleInput)
    func didPressCloseButton(on module: CardSecModuleInput)
    func viewWillDisappear()
}
