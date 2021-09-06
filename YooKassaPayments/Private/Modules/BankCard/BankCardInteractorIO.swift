protocol BankCardInteractorInput: AnalyticsTrack {
    func tokenizeInstrument(id: String, csc: String?, savePaymentMethod: Bool)
    func tokenizeBankCard(cardData: CardData, savePaymentMethod: Bool, savePaymentInstrument: Bool?)
    func makeTypeAnalyticsParameters() -> (authType: AnalyticsEvent.AuthType, tokenType: AnalyticsEvent.AuthTokenType?)
}

protocol BankCardInteractorOutput: AnyObject {
    func didTokenize(_ data: Tokens)
    func didFailTokenize(_ error: Error)
}
