protocol BankCardInteractorInput {
    func tokenizeInstrument(id: String, csc: String?, savePaymentMethod: Bool)
    func tokenizeBankCard(cardData: CardData, savePaymentMethod: Bool, savePaymentInstrument: Bool?)
    func track(event: AnalyticsEvent)
    func analyticsAuthType() -> AnalyticsEvent.AuthType
}

protocol BankCardInteractorOutput: AnyObject {
    func didTokenize(_ data: Tokens)
    func didFailTokenize(_ error: Error)
}
