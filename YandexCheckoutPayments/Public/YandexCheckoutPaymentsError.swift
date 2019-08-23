/// Possible errors
public enum YandexCheckoutPaymentsError: Error {

    /// This error is possible if you use `TokenizationFlow.bankCardRepeat`,
    /// and by paymentMethodId was not found any saved payment methods.
    case paymentMethodNotFound
}
