protocol BankCardInteractorInput: AnalyticsTrack {
    func tokenizeBankCard(
        cardData: CardData,
        savePaymentMethod: Bool
    )
    func makeTypeAnalyticsParameters() -> (
        authType: AnalyticsEvent.AuthType,
        tokenType: AnalyticsEvent.AuthTokenType?
    )
}

protocol BankCardInteractorOutput: AnyObject {
    func didTokenize(
        _ data: Tokens
    )
    func didFailTokenize(
        _ error: Error
    )
}
