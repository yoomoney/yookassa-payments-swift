struct CardSecModuleInputData {

    // MARK: - Init data

    let requestUrl: String
    let redirectUrl: String
    let isLoggingEnabled: Bool
    let isConfirmation: Bool

    // MARK: - Init

    init(
        requestUrl: String,
        redirectUrl: String,
        isLoggingEnabled: Bool,
        isConfirmation: Bool
    ) {
        self.requestUrl = requestUrl
        self.redirectUrl = redirectUrl
        self.isLoggingEnabled = isLoggingEnabled
        self.isConfirmation = isConfirmation
    }
}

protocol CardSecModuleInput: class {}

protocol CardSecModuleOutput: class {
    func didSuccessfullyPassedCardSec(
        on module: CardSecModuleInput,
        isConfirmation: Bool
    )
    func didPressCloseButton(on module: CardSecModuleInput)
    func viewWillDisappear()
}
