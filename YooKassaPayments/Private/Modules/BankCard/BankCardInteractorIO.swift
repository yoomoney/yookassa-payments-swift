protocol BankCardInteractorInput: AnalyticsTrack {
    func validate(
        cardData: CardData
    )
    func fetchBankCardSettings(
        _ cardMask: String
    )
    func tokenizeBankCard(
        cardData: CardData,
        savePaymentMethod: Bool
    )
    func makeTypeAnalyticsParameters() -> (
        authType: AnalyticsEvent.AuthType,
        tokenType: AnalyticsEvent.AuthTokenType?
    )
}

protocol BankCardInteractorOutput: class {
    func didSuccessValidateCardData()
    func didFailValidateCardData(
        errors: [CardService.ValidationError]
    )

    func didFetchBankSettings(
        _ bankSettings: BankSettings
    )
    func didFailFetchBankSettings()

    func didTokenize(
        _ data: Tokens
    )
    func didFailTokenize(
        _ error: Error
    )
}
