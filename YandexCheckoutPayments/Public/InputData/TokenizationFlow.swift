/// Flow for tokenization
public enum TokenizationFlow {

    /// Flow for tokenization several payment methods like:
    /// Bank card, YandexMoney, Sberbank-Online, Apple Pay.
    case tokenization(TokenizationModuleInputData)

    /// Flow for tokenization saved payment methods by payment method id.
    case bankCardRepeat(BankCardRepeatModuleInputData)
}
