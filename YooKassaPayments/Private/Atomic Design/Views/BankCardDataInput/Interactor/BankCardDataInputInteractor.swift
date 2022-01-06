final class BankCardDataInputInteractor {

    // MARK: - VIPER

    weak var output: BankCardDataInputInteractorOutput?

    // MARK: - Initialization

    private let cardService: CardService
    private let bankSettingsService: BankSettingsService
    private let analyticsService: AnalyticsTracking

    init(
        cardService: CardService,
        bankSettingsService: BankSettingsService,
        analyticsService: AnalyticsTracking
    ) {
        self.cardService = cardService
        self.bankSettingsService = bankSettingsService
        self.analyticsService = analyticsService
    }
}

// MARK: - BankCardDataInputInteractorInput

extension BankCardDataInputInteractor: BankCardDataInputInteractorInput {
    func validate(
        cardData: CardData,
        shouldMoveFocus: Bool
    ) {
        guard let errors = cardService.validate(
            cardData: cardData
        ) else {
            output?.didSuccessValidateCardData(cardData)
            return
        }
        output?.didFailValidateCardData(
            errors: errors,
            shouldMoveFocus: shouldMoveFocus
        )
    }

    func fetchBankCardSettings(
        _ cardMask: String
    ) {
        guard let bankSettings = bankSettingsService.bankSettings(
            cardMask
        ) else {
            output?.didFailFetchBankSettings(cardMask)
            return
        }
        output?.didFetchBankSettings(bankSettings)
    }

    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }
}
