/// Flow for tokenization
public enum TokenizationFlow {

    /// Flow for tokenization several payment methods like:
    /// Bank card, YooMoney, Sberbank-Online, Apple Pay.
    case tokenization(TokenizationModuleInputData)

    /// Flow for tokenization stored payment methods by payment method id.
    case bankCardRepeat(BankCardRepeatModuleInputData)
}
